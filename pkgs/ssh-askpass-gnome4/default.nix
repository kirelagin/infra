{ stdenv, fetchFromGitHub, pkg-config, gcr_4, glib }:

stdenv.mkDerivation {
  pname = "ssh-askpass-gnome4";
  version = "2024-01-20";

  src = fetchFromGitHub {
    owner = "openssh";
    repo = "openssh-portable";
    rev = "8023317e22368c32a6391ab8febf13067f669704";  # https://github.com/openssh/openssh-portable/pull/400
    hash = "sha256-ss4A81gmbPo+6k9lo7yxH6oFsqT599bRpbJnLjvE88s=";
  };

  sourceRoot = "source/contrib";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gcr_4
    glib
  ];

  buildPhase = "make gnome-ssh-askpass4";

  installPhase = ''
    mkdir -p "$out/bin"
    cp gnome-ssh-askpass4 "$out/bin"
  '';
}
