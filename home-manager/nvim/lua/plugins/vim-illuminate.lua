return {
  "RRethy/vim-illuminate",

  -- event = { "LazyFile" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    providers = { "lsp", "treesitter" },
    delay = 200,
  },
  config = function(_, opts) require("illuminate").configure(opts) end,
}
