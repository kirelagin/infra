#!/usr/bin/env bash
# A small launcher for the persistent personal Windows VM.
set -euo pipefail

readonly URI="qemu:///system"
readonly DOMAIN="windows"
# Replaced at package build time. Keeping the source default disabled makes it
# safe to run directly too.
readonly USB_CONTROLLER=''
readonly STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly DISK="$STATE_HOME/windows-vm/windows.qcow2"
VIRSH_COMMAND="${VIRSH:-virsh}"
VIRT_INSTALL="${VIRT_INSTALL:-virt-install}"
VIRT_VIEWER="${VIRT_VIEWER:-virt-viewer}"
QEMU_IMG="${QEMU_IMG:-qemu-img}"
ZENITY="${ZENITY:-zenity}"
SYSFS="${SYSFS:-/sys}"

fail() { printf 'windows-vm: %s\n' "$*" >&2; exit 1; }
usage() {
  cat <<'EOF'
Usage: windows-vm [start]
       windows-vm prepare /path/to/Windows.iso

`prepare` creates a sparse 80 GiB disk at
$XDG_STATE_HOME/windows-vm/windows.qcow2 (or ~/.local/state) and defines, but does
not boot, the `windows` VM. It will not overwrite an existing VM or disk.
Install Windows manually in virt-manager or with `windows-vm start`; use
virt-manager for advanced configuration. An optionally configured whole USB
controller PCI BDF is added only during prepare; it is not a USB bus or port
address, and existing domains are unchanged. Change existing VM hardware
manually in virt-manager.

`start` starts the existing VM if it is shut off, then opens its SPICE display.
Closing the viewer disconnects only. If the guest is still running after a
normal viewer exit, a dialog offers graceful Windows shutdown; Disconnect (and
dismissal) leaves it running. Shut down from Windows normally to return USB.

In the viewer Preferences, select and enable any folder to share; it is available
while connected. In Windows, install SPICE guest tools, then the separate
spice-webdavd service:
https://www.spice-space.org/download.html
https://www.spice-space.org/download/windows/spice-webdavd/
Map a File Explorer network drive to http://localhost:9843/.
EOF
}
virsh_command() { "$VIRSH_COMMAND" --connect "$URI" "$@"; }
require_connection() { virsh_command uri >/dev/null || fail "cannot connect to $URI"; }
domain_exists() {
  local names
  names="$(virsh_command list --all --name)" || fail "cannot list domains; refusing to assume '$DOMAIN' is absent"
  grep -Fxq -- "$DOMAIN" <<<"$names"
}
require_domain() {
  domain_exists || fail "VM '$DOMAIN' is missing. Run: windows-vm prepare /path/to/Windows.iso"
}
check_controller() {
  local device="$SYSFS/bus/pci/devices/$USB_CONTROLLER" group member
  [[ -e "$device" ]] || fail "configured USB controller PCI $USB_CONTROLLER is absent"
  [[ -r "$device/class" && "$(<"$device/class")" =~ ^0x0[cC]03[[:xdigit:]]{2}$ ]] || fail "PCI $USB_CONTROLLER is not a USB controller"
  group="$(readlink -f "$device/iommu_group" 2>/dev/null || true)"
  [[ -d "$group/devices" ]] || fail "PCI $USB_CONTROLLER has no IOMMU group"
  for member in "$group"/devices/*; do
    [[ "$(basename "$member")" == "$USB_CONTROLLER" ]] || fail "IOMMU group for $USB_CONTROLLER is not isolated"
  done
}
prepare() {
  (($# == 1)) || fail "prepare needs a Windows ISO path"
  local iso="$1" xml
  local -a hostdev_args=()
  [[ -f "$iso" && -r "$iso" ]] || fail "ISO is not a readable file: $iso"
  require_connection
  if domain_exists; then
    fail "VM '$DOMAIN' already exists; it was not changed"
  fi
  [[ ! -e "$DISK" && ! -L "$DISK" ]] || fail "disk already exists: $DISK"
  if [[ -n "$USB_CONTROLLER" ]]; then
    check_controller
    hostdev_args=(--hostdev "$USB_CONTROLLER")
  fi
  mkdir -p -- "$(dirname "$DISK")"
  "$QEMU_IMG" create -f qcow2 -o preallocation=off "$DISK" 80G >/dev/null || fail "could not create $DISK"
  xml="$(mktemp)"
  trap 'rm -f -- "$xml"' RETURN
  "$VIRT_INSTALL" --connect "$URI" --print-xml --name "$DOMAIN" \
    --memory 4096 --vcpus 4 --cpu host-passthrough --os-variant win11 \
    --boot uefi,loader.secure=yes,bootmenu.enable=yes,cdrom,hd --machine q35 \
    --disk "path=$DISK,format=qcow2,bus=sata" \
    --disk "path=$iso,device=cdrom,readonly=on" --network user,model=e1000e \
    --graphics spice --video qxl \
    --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
    "${hostdev_args[@]}" \
    --channel spiceport,source.channel=org.spice-space.webdav.0,target.name=org.spice-space.webdav.0 >"$xml" || fail "virt-install could not generate VM XML; disk remains at $DISK"
  [[ -s "$xml" ]] || fail "virt-install generated empty VM XML; disk remains at $DISK"
  virsh_command define "$xml" || fail "could not define '$DOMAIN'; disk remains at $DISK"
  printf "VM defined but not started. Open virt-manager or run: windows-vm start\n"
}
maybe_shutdown() {
  local state
  state="$(LC_ALL=C virsh_command domstate "$DOMAIN" 2>/dev/null | xargs)" || return 0
  [[ "$state" == running ]] || return 0
  if "$ZENITY" --question --title="Windows" --text="Windows is still running." \
      --ok-label="Shut down" --cancel-label="Disconnect" --default-cancel; then
    virsh_command shutdown "$DOMAIN" || fail "could not request graceful shutdown of '$DOMAIN'"
  fi
}
start() {
  (($# == 0)) || fail "start takes no options"
  require_connection
  require_domain
  local state
  state="$(LC_ALL=C virsh_command domstate "$DOMAIN" | xargs)" || fail "could not determine VM state"
  case "$state" in
    running) ;;
    "shut off") virsh_command start "$DOMAIN" || fail "could not start '$DOMAIN'" ;;
    *) fail "VM '$DOMAIN' is $state; resolve that state in virt-manager first" ;;
  esac
  if "$VIRT_VIEWER" --connect "$URI" --wait "$DOMAIN"; then
    maybe_shutdown
  else
    return $?
  fi
}
case "${1:-start}" in
  start) if (($#)); then shift; fi; start "$@" ;;
  prepare) shift; prepare "$@" ;;
  -h|--help|help) usage ;;
  *) fail "unknown command '$1'; run windows-vm --help" ;;
esac
