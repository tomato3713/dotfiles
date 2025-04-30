-- ddc.vim の補完例
-- https://github.com/atusy/dotfiles/blob/7f1a22c6e4e4cad43d37571c297b10c30572b921/dot_config/nvim/lua/plugins/ddc/codecompanion.lua#L17
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
			slash_commands = {
				["buffer"] = {
					opts = {
						provider = "mini_pick",
					},
				},
				["file"] = {
					opts = {
						provider = "mini_pick",
					},
				},
				["help"] = {
					opts = {
						provider = "mini_pick",
					},
				},
				["symbols"] = {
					opts = {
						provider = "mini_pick",
					},
				},
				["workspace"] = {
					opts = {
						provider = "mini_pick",
					},
				},
				["actions"] = {
					opts = {
						provider = "mini_pick",
					},
				},
			},
		},
		inline = {
			adapter = "copilot",
		},
		cmd = {
			adapter = "copilot",
		},
	},
	opts = {
		language = "Japanese",
	},
	prompt_library = {
		["With Copilot Instructions"] = {
			strategy = "chat",
			description = "Read and discuss the Copilot instructions from the file",
			opts = {
				auto_submit = false,
				short_name = "copilot",
			},
			references = {
				{
					type = "file",
					path = ".github/copilot-instructions.md",
				},
			},
		},
	},
	display = {
		chat = {
			auto_scroll = true,
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
		diff = {
			enabled = true,
			close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
			layout = "vertical", -- vertical|horizontal split for default provider
			opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
			provider = "default", -- default|mini_diff
		},
	},
})


vim.keymap.set({ 'n', 'v' }, '<leader>cf', ':CodeCompanion<CR>', { silent = true, desc = 'Inline CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':CodeCompanionChat<CR>', { silent = true, desc = 'Chat with CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', ':CodeCompanionActions<CR>',
	{ silent = true, desc = 'Action by CodeCompanion' })

vim.cmd([[cab cc CodeCompanion]])
