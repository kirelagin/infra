return {
  "lewis6991/gitsigns.nvim",

  event = "LazyFile",
  opts = {
    numhl = true,
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      untracked = { text = "┆" },
    },
    on_attach = function(buffer)
      local gs = require("gitsigns")

      local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc }) end

      map("n", "]h", gs.next_hunk, "Next hunk")
      map("n", "[h", gs.prev_hunk, "Prev hunk")
      map({ "n", "v" }, "<leader>chs", gs.stage_hunk, "Stage hunk")
      map({ "n", "v" }, "<leader>chr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>chS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>chu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>chR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>chp", gs.preview_hunk_inline, "Preview hunk inline")
      map("n", "<leader>chb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>chd", gs.diffthis, "Diff this")
      map("n", "<leader>chD", function() gs.diffthis("~") end, "Diff this ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "gitsigns hunk")

      map("n", "<leader>cb", gs.blame, "Blame file")

      local gsc = require("gitsigns.config")
      Snacks.toggle({
        name = "Line blame",
        get = function()
          return gsc.config.current_line_blame
        end,
        set = function(state)
          gs.toggle_current_line_blame(state)
        end,
      }):map("<leader>ub")
    end,
  },
}
