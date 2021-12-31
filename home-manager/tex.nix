{
  programs.texlive = {
    enable = true;
    extraPackages = tp: { inherit (tp)
      scheme-basic
      collection-latexrecommended
      collection-xetex

      catchfile
      datetime2
      tracklang
    ;};
  };
}
