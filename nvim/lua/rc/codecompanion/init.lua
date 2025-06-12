require("rc.codecompanion.fidget-spinner"):init()
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
						provider = "snacks",
					},
				},
				["file"] = {
					opts = {
						provider = "snacks",
					},
				},
				["help"] = {
					opts = {
						provider = "snacks",
					},
				},
				["symbols"] = {
					opts = {
						provider = "snacks",
					},
				},
				["workspace"] = {
					opts = {
						provider = "snacks",
					},
				},
				["actions"] = {
					opts = {
						provider = "snacks",
					},
				},
				["git_files"] = {
					description = "List git files",
					---@param chat CodeCompanion.Chat
					callback = function(chat)
						local handle = io.popen("git ls-files")
						if handle ~= nil then
							local result = handle:read("*a")
							handle:close()
							chat:add_reference({ role = "user", content = result }, "git",
								"<git_files>")
						else
							return vim.notify("No git files available", vim.log.levels.INFO,
								{ title = "CodeCompanion" })
						end
					end,
					opts = {
						contains_code = false,
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
		['Diff code review'] = {
			strategy = 'chat',
			description = 'Perform a code review',
			opts = {
				auto_submit = true,
				user_prompt = false,
			},
			prompts = {
				{
					role = 'user',
					content = function()
						local target_branch = vim.fn.input(
							'Target branch for merge base diff (default: main): ', 'main')

						return string.format(
							[[
以下のコード変更をレビューしてください。
潜在的なバグ、パフォーマンスの問題、セキュリティ上の脆弱性、または可読性や保守性を向上させるためにリファクタリングが可能な箇所を特定してください。
理由を明確に説明し、具体的な改善提案を提供してください。
エッジケース、エラーハンドリング、ベストプラクティスやコーディング標準への準拠も考慮してください。
以下がコード変更です:
           ```
            %s
           ```
           ]],
							vim.fn.system('git diff --merge-base ' .. target_branch)
						)
					end,
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
			provider = "snacks", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
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
	extensions = {
		history = {
			enabled = true,
			opts = {
				keymap = "gh",
				auto_generate_title = true,
				continue_last_chat = false,
				delete_on_clearing_chat = false,
				picker = "snacks",
				enable_logging = false,
				dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
			}
		},
	}
})


vim.keymap.set({ 'n', 'v' }, '<leader>cf', ':CodeCompanion<CR>', { silent = true, desc = 'Inline CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':CodeCompanionChat<CR>', { silent = true, desc = 'Chat with CodeCompanion' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', ':CodeCompanionActions<CR>',
	{ silent = true, desc = 'Action by CodeCompanion' })
vim.cmd([[cab cc CodeCompanion]])
