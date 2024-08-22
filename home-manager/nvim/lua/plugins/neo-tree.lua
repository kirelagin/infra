return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },

  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    window = {
      position = "current",
    },
    filesystem = {
      use_libuv_file_watcher = true,
    },
    document_symbols = {
      follow_cursor = true,
    },
  },
  init = function()
    if vim.fn.argc(-1) == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then require("neo-tree") end
    end
  end,
  cmd = "Neotree",
  keys = {
    {
      "<leader>ff",
      function() require("neo-tree.command").execute({ dir = vim.loop.cwd(), reveal_force_cwd = true }) end,
      desc = "Browse current file",
    },
    {
      "<leader>fd",
      function() require("neo-tree.command").execute({ dir = vim.loop.cwd(), reveal_force_cwd = false }) end,
      desc = "Browse cwd",
    },
    {
      "<leader>ct",
      function()
        require("neo-tree.command").execute({
          source = "document_symbols",
          position = "right",
          action = "show",
          toggle = true,
        })
      end,
      desc = "Toggle LSP tree",
    },
  },
}
