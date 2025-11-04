{ config, lib, pkgs, ... }:

let
  lint-python = pkgs.writeShellScript "lint-python" ''
    ret=0

    printf '# Running flake8:\n'
    ${config.kirelagin.pythonEnv}/bin/flake8 --count "$@"
    [ "$?" -ne 0 ] && ret=1

    printf '# Running mypy:\n'
    ${config.kirelagin.pythonEnv}/bin/mypy --follow-imports=silent --strict "$@"
    [ "$?" -ne 0 ] && ret=1

    exit "$ret"
  '';

  aider-wrapped = pkgs.writeShellScriptBin "aider" ''
    export HOME="${config.xdg.dataHome}/aider"
    mkdir -p -- "$HOME"

    exec ${pkgs.aider-chat-with-help}/bin/aider \
      --config "${config.xdg.configHome}/aider/config.yml" \
      --env-file "${config.xdg.configHome}/aider/env" \
      "$@"
  '';
in

{
  programs.git.ignores = [
    "/.aider*"
  ];

  home.packages = [
    aider-wrapped
  ];

  xdg.configFile."aider/config.yml".text = lib.generators.toYAML {} {
    # Set OPENROUTER_API_KEY=... in a file at ${config.xdg.configHome}/aider/env
    model = "openrouter/anthropic/claude-sonnet-4";
    weak-model = "openrouter/google/gemini-2.5-flash";
    cache-prompts = true;
    cache-keepalive-pings = 10;

    dark-mode = true;
    code-theme = "solarized-dark";

    git = true;
    gitignore = false;

    chat-mode = "ask";
    watch-files = true;

    check-update = false;

    lint-cmd = [
      "python: ${lint-python}"
    ];
  };
}
