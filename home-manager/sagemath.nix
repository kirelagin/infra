{ config, ... }:

{
  programs.sagemath = {
    enable = false;
    initScript = ''
      %colors linux
    '';
  };
}
