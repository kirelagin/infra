{
  global = {
    "q" = "bclose; refresh;";
    "Q" = "exit";
    "d" = "";
    "\\" = "";
    "|" = "";
    "U" = "";
    "I" = "search tag:inbox; sort oldest_first;";
    "T" = "search tag:todo; sort oldest_first;";
  };

  search = {
    "&" = "";
    "l" = "";
    "O" = "";
    "a" = "";

    "/" = "refineprompt";

    # HACK: bug with folding
    "enter" = "select; fold *; fold *; unfold tag:unread; move last; unfold; move first;";

    "t" = "tag todo; untag inbox;";
    "d" = "untag inbox,todo;";
  };

  thread = {
    "C" = "";
    "E" = "";
    "c" = "";
    "e" = "";
    "P" = "";
    "p" = "";
    "g" = "";

    "h" = "move parent";
    "l" = "move first reply";

    "J" = "move next sibling";
    "K" = "move previous sibling";

    "t" = "tag todo; untag --all inbox; refresh; fold;";
    "d" = "untag --all inbox,todo; refresh; fold;";

    "r" = "reply --all";
    "R" = "reply";

    "' '" = "untag unread; fold; move next unfolded;";

    "v" = "pipeto urlscan 2>/dev/null";
  };

  bufferlist = {
    "d" = "close";
  };
}
