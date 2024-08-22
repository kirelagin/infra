return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },

		config = function(_, opts)
			require("telescope").load_extension("frecency")
			require("telescope").load_extension("fzf")
			require("telescope").setup(opts)
		end,
		opts = function()
			-- local actions = require("telescope.actions")
			return {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					mappings = {
						n = {
							["q"] = "close",
						},
						i = {
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
						},
					},
				},
				pickers = {
					find_files = {
						find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
					},
				},
			}
		end,
		cmd = "Telescope",
		keys = {
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<C-_>", "<cmd>Telescope live_grep<cr>", desc = "Grep files" }, -- this is actually <C-/>
			{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep files" },
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
			{ "<leader>ss", "<cmd>Telescope treesitter<cr>", desc = "Find Treesitter nodes" },

			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "List git branches" },
			{ "<leader>gC", "<cmd>Telescope git_commits<cr>", desc = "List git commits for the buffer" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "List git commits" },

			{ "<leader>b/", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Find buffers" },
		},
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("TelescopeLspConfig", {}),
				callback = function(ev)
					local buffer = ev.buf
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					local function map(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
					end

					map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition(s)")
					map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation(s)")
					map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Go to references")
					map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition(s)")

					map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", "Find LSP symbols")
					map("n", "<leader>sr", "<cmd>Telescope lsp_references<cr>", "Find references")
				end,
			})
		end,
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		name = "telescope-fzf-native.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },

		lazy = true,
	},

	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },

		lazy = true,
	},
}
