{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: tpkgs.scheme-basic;
  };
}
