{ pkgs, ... }:

{
  config = {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      dejavu_fonts
      font-awesome
      lato
      nerd-fonts.dejavu-sans-mono
      paratype-pt-sans
      paratype-pt-serif
    ];
  };

}
