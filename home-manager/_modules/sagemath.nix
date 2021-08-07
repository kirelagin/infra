{ config, lib, pkgs, ... }:

let

  cfg = config.programs.sagemath;

  inherit (lib) literalExample mkEnableOption mkIf mkOption types;

  # Upstream does not used XDG by default :(.
  defaultDataDir = "${config.home.homeDirectory}/.sage";

in rec {
  meta.maintainers = [ lib.maintainers.kirelagin ];

  options.programs.sagemath = {
    enable = mkEnableOption "sage";

    package = mkOption {
      type = lib.types.package;
      default = pkgs.sage;
      defaultText = literalExample "pkgs.sage";
      description = "The SageMath package to use.";
    };

    configDir = mkOption {
      type = types.str;
      default = defaultDataDir;
      defaultText = "~/.sage";
      example = literalExample "\${config.xdg.configHome}/sage";
      description = ''
        Directory where the sage.init file will be stored.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = defaultDataDir;
      defaultText = "~/.sage";
      example = literalExample "\${config.xdg.dataHome}/sage";
      description = ''
        Location for $DOT_SAGE.
      '';
    };

    initScript = mkOption {
      type = types.lines;
      default = "";
      example = "%colors linux";
      description = ''
        Contents of the init.sage file that is loaded on startup.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];

      home.file."${cfg.configDir}/init.sage".text = cfg.initScript;
    }

    (mkIf (cfg.configDir != defaultDataDir) {
      home.sessionVariables.SAGE_STARTUP_FILE = "${cfg.configDir}/init.sage";
    })

    (mkIf (cfg.dataDir != defaultDataDir) {
      home.sessionVariables.DOT_SAGE = cfg.dataDir;
    })
  ]);
}
