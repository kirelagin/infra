return {
  "RRethy/vim-illuminate",

  event = { "LazyFile" },
  opts = {
    providers = { "lsp", "treesitter" },
    delay = 200,
  },
  config = function(_, opts) require("illuminate").configure(opts) end,
}
