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
      { "[", desc = "+prev" },
      { "]", desc = "+next" },
      { "g", desc = "+go" },
      { "<leader>b", desc = "+buffers" },
      { "<leader>c", desc = "+code" },
      { "<leader>f", desc = "+files" },
      { "<leader>s", desc = "+search" },
      { "<leader>t", desc = "+tabs" },
      { "<leader>w", desc = "+windows" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(opts.defaults)
  end,
}
