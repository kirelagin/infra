{ pkgs, ... }:

{
  xdg.enable = true;

  accounts.email = {
    maildirBasePath = "./.local/lib/mail";

    accounts.kirelagin = rec {
      address = "kir@elagin.me";
      userName = address;
      realName = "Kirill Elagin";
      passwordCommand = "${pkgs.pass}/bin/pass show email/kir@elagin.me | head -n1";
      primary = true;

      imap.host = "bruna.kir.elagin.me";
      smtp.host = "bruna.kir.elagin.me";
      #imapnotify = {
      #  enable = true;
      #  boxes = [ "Inbox" ];
      #};
      mbsync.enable = true;
      mbsync.create = "maildir";
      msmtp.enable = true;

      notmuch.enable = true;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    new.tags = [ "new" ];
    new.ignore = [ "/.*[.](json|lock|bak)$/" ];
    hooks.preNew = "mbsync --all";
    hooks.postNew = "afew --tag --new";
  };
  programs.afew = {
    enable = true;
  };
  programs.alot = {
    enable = true;
    settings = {
      initial_command = "search tag:inbox; sort oldest_first; # search tag:todo; sort oldest_first; buffer 0;";
      thread_focus_linewise = false;
      msg_summary_hides_threadwide_tags = false;

      attachment_prefix = "~/Downloads";

      theme = "mutt";
      thread_statusbar = "[{buffer_no}: thread] {subject}, {input_queue} messages: {message_count}";
    };
    bindings = import ./alot/bindings.nix;
    hooks = builtins.readFile ./alot/hooks.py;
  };
}
