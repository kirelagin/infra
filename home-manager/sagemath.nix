{ config, ... }:

{
  programs.sagemath = {
    enable = true;
    initScript = ''
      %colors linux
    '';
  };
}
