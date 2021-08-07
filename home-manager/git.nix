{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    userName = "Kirill Elagin";
    userEmail = "kirelagin@gmail.com";

    aliases = {
      st = "status";
      unstage = "reset HEAD --";
      log = "log --format=my-signature";
      glog = "log --graph --date-order --format=my-signature";
      sign = "commit --amend --no-edit -S";
      scrub = "reset --hard @{upstream}";
      hash = "rev-parse HEAD";
      amend = "commit --amend --no-edit";
    };

    extraConfig = {
      help.autocorrect = true;
      color.ui = "auto";
      core.pager = "less -+F -X";

      grep.patternType = "perl";

      init.defaultBranch = "main";
      push.default = "current";
      pull.ff = "only";
      rebase.autosquash = true;

      merge.tool = "diffconflicts";
      mergetool.keepBackup = false;

      "mergetool \"diffconflicts\"" = {
	cmd = ''nvim -c DiffConflicts "$MERGED" "$BASE" "$LOCAL" "$REMOTE"'';
	trustExitCode = true;
      };

      pretty = {
	my = ''format:%C(auto)%h% d%Creset%nDate:   %ai%nAuthor: %aN <%aE>%n%n    %s%n'';
	my-signature = ''format:%C(auto)%h% d%Creset%nDate:   %ai%nAuthor: %aN <%aE>%n%C(dim)Signed: [%G?]% GS%Creset%n%n    %s%n'';
      };
    };

    ignores = [
      ".DS_Store"

      "/.hg/"
      ".hg*"

      "/Session.vim"
      "tags"

      "result"
      "result-*"
      "/.tmp"
    ];
  };
}
