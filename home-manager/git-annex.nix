{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git-annex
    git-annex-remote-rclone
  ];
}
