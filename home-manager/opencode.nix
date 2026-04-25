{ flakes, lib, pkgs, ... }:

let
  models = {
    cheap = "openrouter/minimax/minimax-m2.5:free";
    coding = "anthropic/claude-haiku-4-5";
    coding_advanced = "anthropic/claude-sonnet-4-6";
  };
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

    package = pkgs.opencode.overrideAttrs (origAttrs: {
      postPatch = (origAttrs.postpatch or "") + ''
        substituteInPlace package.json \
              --replace-fail '"packageManager": "bun@1.3.13"' '"packageManager": "bun@${pkgs.bun.version}"'
      '';
    });

    enableMcpIntegration = true;

    tui.theme = "catppuccin";

    settings = {
      model = models.coding;
      small_model = models.cheap;

      default_agent = "plan";

      agent = {
        "plan" =  {
          model = models.coding_advanced;
        };
        "build" = {
          model = models.coding;
        };
      };

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

      plugin = [
        "@ex-machina/opencode-anthropic-auth@1.7.5"
      ];
    };

    commands = {
      "commit" = ''
        ---
        description: Create a Git commit recording the staged changes
        agent: build
        model: ${models.coding_advanced}
        ---

        Commit the changes staged at the moment in the project’s Git repository.
        **Do not** stage any new files.

        1. Check the status of the files (`git status --short`)

        2. Review the staged changes: (`git diff --staged`)

        3. If necessary, take into account the recent history: (`git log --oneline -n 5`)

        4. Make sure the staged changes are self-contained and meaningful. If it looks like they are incomplete,
           or something is missing, stop and ask the user for confirmation.

        5. Based on the collected information, prepare a descriptive commit message following <rules>.

        6. Present the crafted message to the user and ask them to approve it (or provide feedback).
           If there is feedback, incorporate it and try again.

        7. Create the commit by running `git commit` with the appropriate arguments.
           Be careful with the shell syntax when invoking the command, correctly escape the contents
           of the message and make sure there are no extra symbols added.

        <rules>
           The commit message **must** contain three sections:

           1. (title) A one-line summary, following the format established in the repository.
           2. (why) Reason for the changes in the commit, what problem we are solving and why we are making the change.
           3. (how) What the change in the commit does, how exactly it addresses the problem.

           There **must** be a title and there **must** be _at least_ two paragraphs following the structure
           outlined above.

           Here are the best practices for writing the body of the message:

           * Each section should be as brief as possible, but, still, it has to contain all the details necessary
             for understanding the change.
           * Prefer plain-text, however it is perfectly ok to use standard Markdown if this improves readability.
           * Break long lines, preferably at sentence boundaries, or logical boundaries so that the flow of the
             text remains. There is no hard limit, but try to keep each line under 120 characters.
           * Do not describe the code changes itself – the users sees the diff. Focus solely on the semantics.
           * For the (“how”) part, if there are multiple logical changes, prefer a bullet list with each point
             describing one meaningful part of the diff.
           * Never list a bullet list for the “(why)” section.
           * Do not overdo it: if the diff is self-descriptive, the change is easy to understand, and trivial,
             then it is perfectly fine to just have a section consisting of a single sentence.
           * Once again, keep it concise, but descriptive. It should contain exactly the right amount of detail.
           * At the end of the commit message, add the following text verbatim:

             ```
             Co-authored-by: OpenCode <noreply@opencode.ai>
             ```
        </rules>

        $ARGUMENTS
      '';
    };
  };
}
