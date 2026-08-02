{ config, flakes, ... }:

{
  imports = [ flakes.pi.homeModules.default ];

  config = {
    programs.pi.coding-agent = {
      enable = true;

      environment = {
        PI_CODING_AGENT_DIR.value = "${config.xdg.configHome}/pi";
      };

      themes = [ "${flakes.pi-ext}/themes/catppuccin-mocha.json" ];

      extensions = [
        "${flakes.pi-ext}/extensions/leader-key"
      ];

      settings = {
        theme = "catppuccin-mocha";
      };
    };
  };
}
