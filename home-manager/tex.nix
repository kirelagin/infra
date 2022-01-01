{
  programs.texlive = {
    enable = true;
    extraPackages = tp: { inherit (tp)
      scheme-basic
      collection-latexrecommended
      collection-xetex

      blindtext
      catchfile
      datetime2
      enumitem
      multirow
      tracklang
    ;};
  };
}
