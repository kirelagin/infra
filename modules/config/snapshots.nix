{ config, lib, pkgs, ... }:

let
  snappedMountpoints = [ "/home" ];
  snapshotDefaults = {
    FSTYPE = "btrfs";
    ALLOW_GROUPS = [ "wheel" ];
    SYNC_ACL = true;
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 12;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 0;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_YEARLY = 0;
  };
in

{
  config = {
    services.snapper = {
      snapshotInterval = "hourly";

      configs = lib.flip lib.concatMapAttrs config.fileSystems (mp: conf:
        if lib.any (x: mp == x) snappedMountpoints && conf.fsType == "btrfs" then
          { "${lib.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mp)}" = snapshotDefaults // { SUBVOLUME = mp; }; }
        else
        {}
      );
    };

    system.activationScripts = lib.optionalAttrs (config.services.snapper.configs != {}) {
      snapshotSubvolumes = {
        supportsDryActivation = true;
        text = lib.flip lib.concatMapStrings (lib.attrValues config.services.snapper.configs) (cfg: ''
          snap_target="${cfg.SUBVOLUME}/.snapshots"
          if [ ! -e "$snap_target" ]; then
            if [ "$NIXOS_ACTION" == "dry-activate" ]; then
              printf 'would create a btrfs subvolume at "%s"\n' "$snap_target"
            else
              printf 'creating a btrfs subvolume at "%s"\n' "$snap_target"
              "${pkgs.btrfs-progs}/bin/btrfs" subvolume create "$snap_target"
            fi
          fi
        '');
      };
    };
  };
}
