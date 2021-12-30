{
  programs.taskwarrior = {
    enable = true;

    colorTheme = "dark-violets-256";

    config = {
      search.case.sensitive = false;

      # Custom priority values
      uda.priority.values = "C,H,,L,W";
      urgency = {
        uda.priority = {
          C.coefficient = "+6.0";
          H.coefficient = "+1.8";
          L.coefficient = "-1.8";
          W.coefficient = "-6.0";
        };
        user.tag = {
          health.coefficient = "+3.0";
        };
      };

      color = {
        tagged = "";
        uda.priority = {
          C = "rgb401";
          M = "";
          L = "";
          W = "gray14";
        };
      };

      # Next adjustments
      report.next.filter = "+READY limit:page -spb";
    };
  };
}
