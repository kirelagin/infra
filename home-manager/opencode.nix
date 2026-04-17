{ flakes, lib, pkgs, ... }:

let
in

{
  programs.git.ignores = [
    "/.opencode*"
  ];

  nixpkgs.overlays = [
    flakes.opencode.overlays.default
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    tui.theme = "catppuccin";

    settings = {
      model = "openrouter/anthropic/claude-opus-4.6";
      small_model = "openrouter/google/gemini-3-flash-preview";

      default_agent = "plan";

      permission = {
        codesearch = "ask";
        webfetch = "ask";
        websearch = "ask";
      };

      formatter = {
        "black" = {
          command = [ "${pkgs.black}/bin/black" "$FILE" ];
          extensions = [ ".py" ".pyi" ];
        };
        "ruff".disabled = true;
      };
    };

    commands = {
      "commit" = ''
        ---
        description: Create a Git commit recording the staged changes
        agent: build
        ---

        Commit the changes staged at the moment in the project’s Git repository.
        **Do not** stage any new files.

        1. Check the status of the files:

           !`git status --short`

        2. Review the staged changes:

           !`git diff --staged`

        3. If necessary, take into account the recent history:

           !`git log --oneline -n 5`

        4. Make sure the staged changes are self-contained and meaningful. If it looks like they are incomplete,
           or something is missing, stop and ask the user for confirmation.

        5. Based on the collected information, prepare a descriptive commit message.

           The commit message **must** contain three sections:

           1. Commit title (a brief summary, following the format established in the repository)
           2. Reason for the changes in the commit: what problem we are solving and why we are making the change.
           3. What the change in the commit does: how exactly it addresses the problem.

           Keep the commit message concise, but descriptive. It should contain exactly the right amount of detail.
           There **must** be a title and there **must** be _at least_ two paragraphs following the structure
           outlined above.
           Each section should be as brief as possible, but, still, it has to contain all the details necessary
           for understanding the change.
           Do not overdo it: if the diff is self-descriptive, the change is easy to understand, and trivial,
           then it is perfectly fine to just have a section consisting of a single sentence.

        6. At the end of the commit message, add the following text verbatim:

           ```
           Co-authored-by: OpenCode <noreply@opencode.ai>
           ```

        7. Create the commit by running `git commit` with the appropriate arguments.
           Be careful with the shell syntax when invoking the command, correctly escape the contents
           of the message and make sure there are no extra symbols added.
      '';
    };
  };
}
