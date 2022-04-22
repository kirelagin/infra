# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.secrets;

  secret = types.submodule ({ name , ... }: {
    options = {
      path = mkOption {
        type = types.path;
        default = "${cfg.location}/${name}";
        readOnly = true;
        description = "Path to the file containing the secret value.";
      };

      owner = mkOption {
        type = types.str;
        default = "root:root";
        description = "Ensure the ownership of the file.";
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

  ensureSecret = _name: opts: ''
    if [ ! -f  "${opts.path}" ]; then
      echo >&2 'Secret file `${opts.path}` does not exist.'
      missing_secrets=1
    else
      chown '${opts.owner}' '${opts.path}'
      chmod '${opts.permissions}' '${opts.path}'
    fi
  '';
in

{
  options.secrets = {
    secrets = mkOption {
      type = types.attrsOf secret;
      default = {};
      description = "Secrets that have to be present.";
    };

    location = mkOption {
      type = types.path;
      default = "/var/lib/secrets";
      description = "Directory where the secrets are stored.";
    };
  };

  config = {
    system.activationScripts = {
      secrets = {
        supportsDryActivation = true;
        text = ''
          missing_secrets=0
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList ensureSecret cfg.secrets)}
          [ $missing_secrets -eq 0 ]  # assert
        '';
      };

      # Activate users after secrets in case there are some user passwords
      users.deps = [ "secrets" ];
    };
  };
}
