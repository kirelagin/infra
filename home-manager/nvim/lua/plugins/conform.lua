return {
  "stevearc/conform.nvim",

  -- event = { "LazyFile" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    formatters_by_ft = {
      cpp = { "clang-format" },
      lua = { "stylua" },
      nix = { "nixfmt" },
      python = { "black" },
    },
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 500,
    },
    format_after_save = {
      lsp_fallback = true,
    },
  },
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ timeout_ms = 1000 }) end,
      mode = { "n", "v" },
      desc = "Format",
    },
    {
      "<leader>cF",
      function() require("conform").format({ formatters = { "injected" }, timeout_ms = 1000 }) end,
      mode = { "n", "v" },
      desc = "Format injected",
    },
  },
}
