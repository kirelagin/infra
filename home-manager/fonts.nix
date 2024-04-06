{ pkgs, ... }:

{
  config = {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      dejavu_fonts
      font-awesome
      lato
(pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
      paratype-pt-sans
      paratype-pt-serif
    ];
  };

}
