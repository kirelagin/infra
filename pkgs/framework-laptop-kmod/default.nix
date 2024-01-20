{ stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation {
  pname = "framework-laptop-kmod";
  version = "2023-10-08";

  src = fetchFromGitHub {
    owner = "DHowett";
    repo = "framework-laptop-kmod";
    rev = "fed64af4c19a15ef6bb7dca79b692d265e845699";
    hash = "sha256-27UvugtHwwDt6kIZx4bdb/urpKAXafeqkaqlUAGugYE=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  installTargets = [ "modules_install" ];
}
