return {
  "folke/snacks.nvim",

  priority = 1000,
  lazy = false,

  opts = {
    bigfile = { enabled = true },
    dim = {
      enabled = true,
      animate = { enabled = false },
    },
    input = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    toggle = { enabled = true },

    styles = {
      zen = {
        width = 180,
        backdrop = 0,
      },
    },
  },

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle.dim():map("<leader>uD")
        Snacks.toggle.line_number():map("<leader>un")
        Snacks.toggle.zen():map("<leader>uZ")
      end,
    })
  end,
}
