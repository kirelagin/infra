{ config, lib, pkgs, ... }:

let
  lint-python = pkgs.writeShellScript "lint-python" ''
    ret=0

    printf '# Running flake8:\n'
    ${pkgs.python3Packages.flake8}/bin/flake8 --count "$@"
    [ "$?" -ne 0 ] && ret=1

    printf '# Running mypy:\n'
    ${pkgs.mypy}/bin/mypy --follow-imports=silent --strict "$@"
    [ "$?" -ne 0 ] && ret=1

    exit "$ret"
  '';
in

{
  programs.git.ignores = [
    "/.aider*"
  ];

  home.packages = [
    pkgs.aider-chat-with-help
  ];

  home.file.".aider.conf.yml".text = lib.generators.toYAML {} {
    # Set OPENROUTER_API_KEY=... in a `.env` file
    model = "openrouter/anthropic/claude-sonnet-4";
    weak-model = "openrouter/google/gemini-2.5-flash";
    cache-prompts = true;
    cache-keepalive-pings = 10;

    dark-mode = true;
    code-theme = "solarized-dark";

    git = true;
    gitignore = false;

    watch-files = true;

    lint-cmd = [
      "python: ${lint-python}"
    ];
  };
}
