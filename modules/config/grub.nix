# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ ... }:

{
  config = {
    boot.loader.grub = {
      enable = true;
      version = 2;
    };
  };
}
