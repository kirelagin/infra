{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = false;

    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      ignoreDups = true;  # TODO: should be IGNORE_ALL_DUPS
      ignoreSpace = true;
      share = true;
    };

    defaultKeymap = "viins";

    initContent = ''
      setopt HIST_REDUCE_BLANKS  # TODO: make into an option

      bindkey -M viins '^x' push-line

      # Use `ls` colours
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # matches case insensitive for lowercase
      zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

      # pasting with tabs doesn’t perform completion
      zstyle ':completion:*' insert-tab pending


      # Directory stack
      ##################

      DIRSTACKSIZE=10
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS


      ###
      ########################
      ###

      setopt NO_CLOBBER           # do not allow > to overwrite files and >> to create new ones
      setopt HIST_ALLOW_CLOBBER   # rewrite a line before storing so that it is not subject to NO_CLOBBER
      setopt CORRECT              # correct invalid command names
      #setopt EXTENDED_GLOB        # regexps in globs


      if [[ -a ~/.localrc ]]
      then
        source ~/.localrc
      fi
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    LS_COLORS = "di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;34;46:cd=1;34;43:su=1;30;41:sg=1;30;46:tw=1;30;42:ow=1;30;43";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    LSCOLORS = "ExFxCxDxBxEgEdAbAgAcAd";
  };

  home.shellAliases = {
    grep = "grep --color=auto";
    egrep = "egrep --color=auto";
    man = "LANG=C man";
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    ls = "ls -v --color=auto";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    ls = "ls -G";
  } // lib.optionalAttrs config.programs.zoxide.enable {
    cd = "z";
  };

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      keymap = "vi-command";

      colored-stats = true;
      completion-ignore-case = true;
      mark-symlinked-directories = true;

      show-all-if-ambiguous = true;
      show-all-if-unmodified = true;
    };
  };


  programs.nushell = {
    enable = true;

    shellAliases = {
      e = "nvim";
    };

    extraConfig = ''
      $env.config = {
        show_banner: false
        edit_mode: "vi"
        shell_integration: true
      }

      const local_rc = ~/.config/nushell/local.nu
      if ($local_rc | path exists) { source $local_rc }
    '';
  };

  programs.carapace.enable = true;

  programs.zoxide.enable = true;

  #programs.starship.enable = true;

}
