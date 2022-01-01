{ config, ... }:

{
  imports = [
    ./gdb.nix
    ./gnupg.nix
    ./git.nix
    ./git-annex.nix
    ./haskell.nix
    ./homebrew.nix
    ./idea.nix
    ./lldb.nix
    ./mail.nix
    ./nvim.nix
    ./pandoc.nix
    ./sagemath.nix
    ./shell.nix
    ./taskwarrior.nix
    ./tex.nix
    ./tmux.nix
    ./tools.nix

    ./desktop/linux.nix
  ];

  config = {
    xdg.enable = true;
  };
}
