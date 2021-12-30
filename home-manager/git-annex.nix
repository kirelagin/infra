{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gitAndTools.git-annex
    gitAndTools.git-annex-remote-rclone
  ];
}
