{ pkgs, ... }:

{
  config = {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      dejavu_fonts
      font-awesome
      lato
      paratype-pt-sans
      paratype-pt-serif
    ];
  };

}
