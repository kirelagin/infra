local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


----
---- Editor
----

-- Sane movement with wrap turned on
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "i" }, "<Down>", "<C-o>gj")
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "i" }, "<Up>", "<C-o>gk")

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Sane behaviour for n/N in search results
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Use C-j and C-k in autocomplete menu
map("i", "<C-j>", '<C-n>')
map("i", "<C-k>", '<C-p>')

--
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- Better indentation
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Jumps
map("n", "[q", vim.cmd.cprev, { desc = "Prev quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })


----
---- Windows / buffers
----

-- Navigation with ctrl
map("n", "<C-h>", "<C-w>h", { desc = "Window to the left", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Window below", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Window above", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Window to the right", remap = true })
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Close window" })
map("n", "<leader>wq", "<cmd>q<cr>", { desc = "Close window" })

-- Tab navigation
map("n", "<leader>t[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader>t]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "Close tab" })

-- Resize windows using ctrl+arrow
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Window height +2" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Window height -2" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Window width -1" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Window width +1" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to the other buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to the other buffer" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-l><cr>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)


----
---- Terminal
----

map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Window to the left" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Window below" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Window above" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Window to the right" })
