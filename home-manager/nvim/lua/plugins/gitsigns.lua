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
      map({ "n", "v" }, "<leader>ghs", gs.stage_hunk, "Stage hunk")
      map({ "n", "v" }, "<leader>ghr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>ghd", gs.diffthis, "Diff this")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "gitsigns hunk")
    end,
  },
}
