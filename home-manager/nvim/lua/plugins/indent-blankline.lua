return {
  "lukas-reineke/indent-blankline.nvim",

  main = "ibl",
  -- event = "LazyFile",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    scope = { enabled = false },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
    },
  },
}
