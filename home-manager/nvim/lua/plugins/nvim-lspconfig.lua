return {
  {
    "neovim/nvim-lspconfig",

    event = { "LazyFile", },
    opts = {
      setup = {
        ccls = {},
        lua_ls = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
        pyright = {},
      },
    },
    config = function(_, opts)
      local lspc = require("lspconfig")
      for server, settings in pairs(opts.setup) do
        lspc[server].setup({ settings = settings })
      end
    end,
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local buffer = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          -- Enable completion triggered by <c-x><c-o>
          vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"

          local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc }) end
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

          map("n", "K", vim.lsp.buf.hover, "LSP hover")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
          map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, "Run codelens")
          map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
          --map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          --map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          --map("n", "<space>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
          --map("n", "<space>D", vim.lsp.buf.type_definition, opts)
          --map("n", "<space>f", function() vim.lsp.buf.format({ async = true }) end, opts)

          vim.keymap.set("n", "<leader>cr", function()
            require("inc_rename")
            return ":IncRename " .. vim.fn.expand("<cword>")
          end, { expr = true, desc = "Rename" })
        end,
      })
    end,
  },

  {
    "smjonas/inc-rename.nvim",

    cmd = "IncRename",
    opts = {
      input_buffer_type = "dressing",
    },
    config = function(_, opts) require("inc_rename").setup(opts) end,
  },
}
