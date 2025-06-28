{ pkgs, ... }:

let
  retroarch = pkgs.retroarch.withCores (cores: with cores; [
    bsnes
  ]);
in

{
  home.packages = [
    retroarch
  ];
}
