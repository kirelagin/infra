local M = {}

function M.setup()
	require("config.options")
	require("config.keymap")
	require("config.autocmds")
end

return M
