{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    withPython3 = true;
    withRuby = false;

    extraConfig = ''
      source ${./nvim}/init.vim
    '';
  };
}
