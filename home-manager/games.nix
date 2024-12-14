{ pkgs, ... }:

let
  retroarch = pkgs.retroarch.override {
    cores = with pkgs.libretro; [
      bsnes
    ];
  };
in

{
  home.packages = [
    retroarch
  ];
}
