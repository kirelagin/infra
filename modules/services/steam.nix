{ pkgs, lib, ... }:

{
  programs.steam.enable = true;
  unfree.pkgnames = [
    "steam"
    "steamcmd"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
  ];
  environment.systemPackages = with pkgs; [
    steamcmd
    steam-tui
  ];
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
}
