{
  programs.texlive = {
    enable = true;
    extraPackages = tp: { inherit (tp) scheme-basic; };
  };
}
