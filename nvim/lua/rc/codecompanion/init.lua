require('codecompanion').setup({
	strategies = {
		chat = {
			adapter = "copilot",
			roles = {
				llm = function(adapter)
					return "  CodeCompanion (" .. adapter.formatted_name .. ")"
				end,
				user = "  Me",
			},
		},
		inline = {
			adapter = "copilot",
		},
	},
	opts = {
		language = "Japanese",
	},
	display = {
		chat = {
			auto_scroll = false,
			show_header_separator = true,
		},
	},
})


vim.keymap.set({ 'n', 'v' }, '<leader>cf', ':CodeCompanion<CR>', { silent = true, desc = 'Inline CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':CodeCompanionChat<CR>', { silent = true, desc = 'Chat with CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', ':CodeCompanionActions<CR>',
	{ silent = true, desc = 'Action by CodeCompanion' })
