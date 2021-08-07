{ config, ... }:

{
  programs.sagemath = {
    enable = true;
    configDir = "${config.xdg.configHome}/sage";
    dataDir = "${config.xdg.dataHome}/sage";
    initScript = ''
      %colors linux
    '';
  };
}
