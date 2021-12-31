lib: pkgs:

pkgs.writeShellScriptBin "whicher" ''
  path=$(command -v "$1")
  if [ "$?" -ne 0 ]; then
    echo >&2 "$1: not found"
    exit 1
  else
    ${lib.getBin pkgs.coreutils}/bin/readlink -f "$path"
  fi
''
