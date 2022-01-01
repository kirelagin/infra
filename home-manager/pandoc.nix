{ pkgs, ... }:

let
  styles = pkgs.fetchFromGitHub {
    owner = "citation-style-language";
    repo = "styles";
    rev = "f78c707d30dcfb280a1d41f9b4915aa02ab4dade";
    hash = "sha256-28XWeab2tkGIcKkqn1hgkGooACWBwukBu8mMur1gMbM=";
  };

in {
  programs.pandoc = {
    enable = true;

    defaults = {
      pdf-engine = "xelatex";
    };

    templates = {
      "kirelagin.latex" = ./pandoc/templates/kirelagin.latex;
      "assignment.latex" = ./pandoc/templates/assignment.latex;
    };

    citationStyles = [
      "${styles}/ieee-with-url.csl"
    ];
  };
}
