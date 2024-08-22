----
-- UI
--

vim.opt.signcolumn = "yes" -- always show gutter
vim.opt.cursorline = true -- highlight current line
vim.opt.list = true
vim.opt.listchars = { tab = "▒░", trail = "▓", nbsp = "␣" }
vim.opt.mouse = "a" -- enable mouse

vim.opt.hidden = true -- hide buffers when closing

vim.opt.visualbell = true
vim.g.t_vb = "" -- disable bell

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3

vim.opt.wildmode = "longest:full,full" -- Command-line completion mode

vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

vim.opt.conceallevel = 2 -- do not show concealed text unless it has a marker

----
-- Editing
--

vim.optexrc = true -- execute ./.nvim.lua

vim.opt.encoding = "utf-8"
vim.opt.termencoding = "utf-8"

vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3

vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftround = true

vim.opt.virtualedit = { "block", "onemore" }
vim.opt.linebreak = true -- do not break lines randomly

if not vim.env.SSH_TTY then
  -- vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
end

vim.api.nvim_create_autocmd("FileType", {
  -- Has to be done this way, can’t be set globally because vim is weird
  callback = function()
    vim.opt.formatoptions:append("cn") -- wrap comments and detect numbered lists
    vim.opt.formatoptions:remove("o") -- do not insert the comment character on `o` and `O`
  end,
})

----
-- Search and replace
--

vim.opt.gdefault = true -- `g` flag by default in searches
vim.opt.hlsearch = true -- highlight results
vim.opt.incsearch = true -- incremental search
vim.opt.ignorecase = true -- /i by default
vim.opt.smartcase = true
