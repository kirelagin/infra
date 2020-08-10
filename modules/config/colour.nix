# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

# Assign colours to NixOS systems.
{ lib, ... }:

{
  options.colour = {
    css = lib.mkOption {
      type = lib.types.strMatching "#[0-9A-Fa-f]{3}|#[0-9A-Fa-f]{6}";
      description = "CSS colour for this system";
      example = "#ffffff";
    };
  };

}
