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
		action_palette = {
			prompt = "Prompt ", -- Prompt used for interactive LLM calls
			provider = "mini_pick", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
			opts = {
				show_default_actions = true, -- Show the default actions in the action palette?
				show_default_prompt_library = true, -- Show the default prompt library in the action palette?
			},
		},
	},
})


vim.keymap.set({ 'n', 'v' }, '<leader>cf', ':CodeCompanion<CR>', { silent = true, desc = 'Inline CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':CodeCompanionChat<CR>', { silent = true, desc = 'Chat with CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', ':CodeCompanionActions<CR>',
	{ silent = true, desc = 'Action by CodeCompanion' })
