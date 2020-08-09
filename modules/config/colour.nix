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
