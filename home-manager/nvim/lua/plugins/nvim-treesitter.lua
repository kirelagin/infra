return {
  {
    "nvim-treesitter/nvim-treesitter",
    name = "nvim-treesitter",
    event = { "LazyFile" },
    config = function()
      local function start_ts()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = start_ts,
      })

      -- When nvim starts without a file and then :e <file> is used, lazy.nvim's
      -- event handler re-fires BufReadPost for newly-registered augroups (e.g.
      -- gitsigns, treesitter-context). This sets Neovim's internal did_filetype
      -- flag, so when the original BufReadPost chain resumes, filetypedetect
      -- sees did_filetype()==1 and skips filetype detection entirely. We use
      -- vim.filetype.match() to bypass the did_filetype() check, and also
      -- handle the case where filetype was already detected but our FileType
      -- autocmd was registered too late to catch it.
      if vim.bo.filetype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
        local ft = vim.filetype.match({ buf = 0 })
        if ft then
          vim.bo.filetype = ft
        end
      elseif vim.bo.filetype ~= "" then
        start_ts()
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    opts = { mode = "topline", max_lines = 5 },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        desc = "Jump to context (upwards)",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move  = { set_jumps = true },
      })

      local move   = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")

      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function" })
      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Previous function" })

      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end, { desc = "a function" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end, { desc = "inner function" })
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end, { desc = "a class" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end, { desc = "inner class" })
    end,
  },
}
