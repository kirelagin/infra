return {
  "sphamba/smear-cursor.nvim",

  -- event = "LazyFile",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    legacy_computing_symbols_support = true,
  },
}
