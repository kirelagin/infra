{
  programs.texlive = {
    enable = true;
    extraPackages = tp: { inherit (tp)
      scheme-basic
      collection-latexrecommended
      collection-xetex

      aligned-overset
      blindtext
      catchfile
      datetime2
      enumitem
      multirow
      tracklang
    ;};
  };
}
