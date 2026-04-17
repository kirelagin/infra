{ config, ... }:

{
  imports = [
    # ./aider.nix  # FIXME
    ./fonts.nix
    ./games.nix
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
    ./opencode.nix
    ./pandoc.nix
    ./python.nix
    ./sagemath.nix
    ./shell.nix
    #./taskwarrior.nix
    ./tex.nix
    ./tmux.nix
    ./tools.nix

    ./desktop/linux.nix
  ];

  config = {
    xdg.enable = true;
    home.stateVersion = "23.05";
    systemd.user.sessionVariables = config.home.sessionVariables;
    programs.home-manager.enable = true;
  };
}
