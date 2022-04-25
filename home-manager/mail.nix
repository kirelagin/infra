{ pkgs, ... }:

{
  accounts.email = {
    maildirBasePath = "./.local/lib/mail";

    accounts.kirelagin = rec {
      address = "kir@elagin.me";
      userName = address;
      realName = "Kirill Elagin";
      passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup xdg:schema org.gnome.Geary login kir@elagin.me";
      primary = true;

      imap.host = "bruna.kir.elagin.me";
      smtp.host = "bruna.kir.elagin.me";
      imapnotify = {
        enable = true;
        boxes = [ "INBOX" "Archive" ];
        onNotify = "systemctl --user start mbsync.service";
        extraConfig = {
          wait = 5;
        };
      };
      mbsync = {
        enable = true;
        create = "both";
        remove = "both";
        expunge = "both";
      };
      msmtp.enable = true;

      notmuch.enable = true;
    };
  };

  # This is complicated really.
  #
  # imapnotify -starts-> mbsync.service
  # mbsync.service -runs-> afew --move
  #           then syncs
  #           then -runs-> notmuch new
  # notmuch new -runs-> afew --tag && afew --move
  #
  # NOTE: simply running `mbsync` only syncs and does not call anything!
  #
  # mbsync.service is also started by a timer, just in case
  #
  # NOTE: _local_ changes are not watched for :/

  services.imapnotify.enable = true;
  services.mbsync = {
    enable = true;
    frequency = "*:0/10";  # every 10 minutes
    preExec = "${pkgs.afew}/bin/afew --move --all";
    postExec = "${pkgs.notmuch}/bin/notmuch new";
  };

  programs.mbsync = {
    enable = true;
    extraConfig = ''
      CopyArrivalDate yes
    '';
  };
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    new.tags = [ "new" ];
    new.ignore = [ "/.*[.](json|lock|bak)$/" ];
    hooks.postNew = "afew --tag --all && afew --move --all";
  };
  programs.afew = {
    enable = true;
    extraConfig = ''
      [SpamFilter]

      [ListMailsFilter]

      [FolderNameFilter]
      maildir_separator = /
      folder_blacklist = Inbox
      folder_transforms = Junk:spam Drafts:draft Sent:sent Archive:archive
      folder_lowercases = true

      [Filter.1]
      query = (tag:new OR tag:inbox) AND tag:sent
      tags = -new;-inbox
      message = Archiving sent emails

      [Filter.2]
      query = (tag:new OR tag:inbox) AND tag:archive
      tags = -new;-inbox
      message = Archiving emails from the Archive directory

      [InboxFilter]

      [MailMover]
      rename = True
      folders = kirelagin/Inbox kirelagin/Archive kirelagin/Junk
      kirelagin/Inbox = 'tag:spam':kirelagin/Junk 'NOT tag:inbox':kirelagin/Archive
      kirelagin/Archive = 'tag:inbox':kirelagin/Inbox
      kirelagin/Junk = 'NOT tag:spam AND tag:inbox':kirelagin/Inbox 'NOT tag:spam':kirelagin/Archive
    '';
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

