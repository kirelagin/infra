{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    withPython3 = true;
    withRuby = false;
    extraPackages = lib.optional pkgs.stdenv.isLinux pkgs.xclip;

    extraConfig = ''
      source ${./nvim}/init.vim
    '';
  };
}
