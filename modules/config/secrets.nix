# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.secrets;

  secret = types.submodule ({ name , ... }: {
    options = {
      path = mkOption {
        type = types.path;
        default = config.age.secrets.${name}.path;
        readOnly = true;
        description = "Path to the file containing the secret value.";
      };

      owner = mkOption {
        type = types.str;
        default = "root";
        description = "Ensure the owner of the file.";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = "Ensure the group of the file.";
      };

      permissions = mkOption {
        type = types.addCheck types.str
          (perm: !isNull (builtins.match "[0-7]{3}" perm));
        default = "400";
        description = "Ensure the permissions of the file.";
      };

      __toString = mkOption {
        readOnly = true;
        visible = false;
        default = self: "${self.path}";
      };
    };
  });
in

{
  imports = [ flakes.agenix.nixosModules.default ];

  options.secrets = {
    secrets = mkOption {
      type = types.attrsOf secret;
      default = {};
      description = "Secrets that have to be present.";
    };
  };

  config = {
    age.secrets = lib.mapAttrs (n: v: { inherit (v) owner group; file = ../../secrets + "/${n}.age"; }) cfg.secrets;
  };
}
