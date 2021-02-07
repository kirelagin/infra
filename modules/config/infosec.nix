# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      openvpn
      (python2.withPackages (pp: with pp; [ pip setuptools wheel ]))
      (python3.withPackages (pp: with pp; [ pip setuptools wheel ]))
      tmux

      binutils
      exiftool
      gdb
      ghidra-bin
      nmap
      openssl
      python3Packages.binwalk
      qemu
      radare2
      samba
      sqlite
      steghide
      wine
      wireshark
      #yara
    ];

  };
}
