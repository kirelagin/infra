return {
  "nvim-lualine/lualine.nvim",

  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  init = function() vim.o.showmode = false end,
  opts = {
    globalstatus = false,
    sections = {
      lualine_b = {
        { "branch" },
        {
          "diff",
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = {
            modified = "",
            readonly = "",
          },
        },
      },

      lualine_x = {
        { "diagnostics" },
        { "filetype" },
      },
    },
    extensions = { "fugitive", "lazy" },
  },
}
