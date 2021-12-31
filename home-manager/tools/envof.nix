lib: pkgs:

pkgs.writeShellScriptBin "envof" ''
  pids=$(${lib.getBin pkgs.procps}/bin/pidof "$1")
  if [ "$?" -ne 0 ]; then
    echo >&2 "$1: not found"
    exit 1
  else
    if echo "$pids" | grep ' ' >/dev/null; then
      for pid in $(echo "$pids"); do
        exe=$(cat /proc/$pid/cmdline | tr '\0' ' ' | cut -d' ' -f1)
        echo >&2 "found: $(basename "$exe")($pid)"
      done
      exit 1
    else
      cat /proc/$pids/environ | tr '\0' '\n'
    fi
  fi
''
