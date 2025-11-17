return {
  "tpope/vim-fugitive",

  enabled = false,

  event = "LazyFile",
  config = function()
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { desc = desc })
    end

    map("n", "<leader>gb", ":Git blame", "Blame current file<CR>")
  end,
}
