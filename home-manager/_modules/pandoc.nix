{ config, lib, pkgs, ... }:

let

  cfg = config.programs.pandoc;

  inherit (lib) literalExpression mkEnableOption mkIf mkOption types;

  defaultsFormat = pkgs.formats.json {};

  makeTemplateFile = name: file:
    lib.nameValuePair "pandoc/templates/${name}" { source = file; };

  getFileName = file:
    # This is actually safe here, since it is just a file name
    builtins.unsafeDiscardStringContext (baseNameOf file);

  makeCslFile = file:
    lib.nameValuePair "pandoc/csl/${getFileName file}" { source = file; };

in rec {
  meta.maintainers = [ lib.maintainers.kirelagin ];

  options.programs.pandoc = {
    enable = mkEnableOption "pandoc";

    package = mkOption {
      type = types.package;
      default = pkgs.pandoc;
      defaultText = literalExpression "pkgs.pandoc";
      description = "The pandoc package to use.";
    };

    # We wrap the executable to pass some arguments
    wrappedPackage = mkOption {
      readOnly = true;
      type = types.package;
      description = "Resulting package";
    };

    defaults = mkOption {
      type = defaultsFormat.type;
      default = { };
      description = ''
        Options to set by default.
        These will be converted to JSON and written to a defaults
        file (see Default files in pandoc documentation).
      '';
      example = literalExpression ''
        {
          metadata = {
            author = "John Doe";
          };
          pdf-engine = "xelatex";
          citeproc = true;
        }
      '';
    };

    defaultsFile = mkOption {
      readOnly = true;
      type = types.path;
      description = "Resulting defaults file";
    };

    templates = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Custom templates";
      example = literalExpression ''
        {
          "default.latex" = path/to/your/template;
        }
      '';
    };

    citationStyles = mkOption {
      type = types.listOf types.path;
      default = [];
      description = "List of .csl files to install";
      example = literalExpression ''
        [ path/to/file.csl ]
      '';
    };

  };

  config = mkIf cfg.enable {
    programs.pandoc = {
      defaultsFile = defaultsFormat.generate "hm.json" cfg.defaults;

      wrappedPackage = pkgs.symlinkJoin {
        name = "pandoc-with-defaults";
        paths = [ cfg.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/pandoc" \
            --add-flags '--defaults "${cfg.defaultsFile}"'
        '';
      };
    };

    home.packages = [ cfg.wrappedPackage ];
    xdg.dataFile =
      lib.mapAttrs' makeTemplateFile cfg.templates //
      lib.listToAttrs (map makeCslFile cfg.citationStyles);
  };
}
