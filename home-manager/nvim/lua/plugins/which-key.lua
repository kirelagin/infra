return {
  "folke/which-key.nvim",

  event = { "VeryLazy" },
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 400
  end,
  opts = {
    defaults = {
      mode = { "n", "v" },
      ["["] = "+prev",
      ["]"] = "+next",
      ["g"] = "+go",
      ["<leader>b"] = "+buffers",
      ["<leader>c"] = "+code",
      ["<leader>f"] = "+files",
      ["<leader>s"] = "+search",
      ["<leader>t"] = "+tabs",
      ["<leader>w"] = "+windows",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
