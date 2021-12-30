{ config, ... }:

{
  imports = [
    ./ghc.nix
    ./gdb.nix
    ./gnupg.nix
    ./git.nix
    ./git-annex.nix
    ./homebrew.nix
    ./idea.nix
    ./lldb.nix
    ./mail.nix
    ./sagemath.nix
    ./taskwarrior.nix
    ./tmux.nix
    ./tools.nix
  ];

  config = {
    xdg.enable = true;
  };
}
