{ pkgs, lib, ... }:

{
  programs.steam.enable = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steamcmd"
    "steam-original"
    "steam-run"
  ];
  environment.systemPackages = with pkgs; [
    steamcmd
    steam-tui
  ];
}
