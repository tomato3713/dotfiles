local _M = {}

local helper = require('rc.helper.ddu')
local ff_helper = require('rc.ddu.ui-ff')
local filer_helper = require('rc.ddu.ui-filer')

local function setup_ui_params()
	helper.patch_global('ui', 'ff')
	helper.patch_global('uiParams', {
		ff = ff_helper.ui_params,
		filer = filer_helper.ui_params,
	})
end


-- setup language server sources
local function setup_lsp_sources()
	helper.patch_global('kindOptions', {
		lsp = { defaultAction = 'open' },
		lsp_codeAction = { defaultAction = 'apply' },
	})

	helper.patch_local('lsp_callHierarchy', {
		sources = {
			helper.separator('>>callHierarchy/outgoingCalls<<', '#fc514e'),
			{
				name = 'lsp_callHierarchy',
				params = { method = 'callHierarchy/outgoingCalls' },
			},
			helper.separator('>>callHierarchy/incommingCalls<<', '#5e97ec'),
			{
				name = 'lsp_callHierarchy',
				params = { method = 'callHierarchy/incommingCalls' },
			},
		},
		uiParams = {
			ff = {
				displayTree = true,
			}
		}
	})

	helper.patch_local('lsp_implementation', {
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/implementation',
			},
		},
	})

	helper.patch_local('lsp_declaration', {
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/declaration',
			},
		},
	})

	helper.patch_local('lsp_typeDefinition', {
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/typeDefinition',
			},
		},
	})

	helper.patch_local('lsp_definition', {
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/definition',
			},
		},
	})
end

_M.setup = function()
	setup_ui_params()

	helper.patch_global('sourceOptions', {
		_ = {
			ignoreCase = true,
			maxItems = 500,
			matchers = {
				'matcher_substring',
			},
		},
		dummy = {
			matchers = {},
			sorters = {},
			converters = {},
		},
		file = {
			columns = { 'filename' },
		},
		file_rec = {
			converters = {
				'converter_relativepath',
				'converter_devicon',
			},
		},
		mr = {
			matchers = {
				'matcher_kensaku',
				'merge',
			},
			converters = {
				'converter_relativepath',
				'converter_devicon',
			},
		},
	})

	helper.patch_global('sourceParams', {
		rg = {
			args = {
				'--smart-case',
				'--column',
				'--no-heading',
				'--color',
				'never'
			}
		},
	})

	helper.patch_global('filterParams', {
		matcher_substring = { highhtMatched = 'Search' },
	})

	helper.patch_global('kindOptions', {
		help = { defaultAction = 'open' },
		file = { defaultAction = 'open' },
		colorscheme = { defaultAction = 'set' },
		chooseAction = { defaultAction = 'do' },
		tab = { defaultAction = 'open' },
		action = { defaultAction = 'do' },
	})

	helper.patch_local('node-files', {
		sources = { 'file_rec' },
		sourceParams = {
			file_rec = {
				ignoredDirectories = { '.git', 'node_modules', 'vendor', '.next', '.vscode', 'tmp' },
			},
		},
	})

	helper.patch_local('jp-files', {
		sources = { 'file_rec' },
		sourceOptions = {
			file_rec = {
				matchers = {
					'matcher_kensaku',
				},
			},
		},
	})

	setup_lsp_sources()
end



-- mappings
_M.set_keymap = function()
	local res = {
		{
			key = ',h',
			config = {
				sources = { 'help' },
				-- uiParams = { ff = { startFilter = true } }
			}
			,
			desc = 'ddu: help tags source'
		},
		{ key = ',o', config = { sources = { 'mr' } },     desc = 'ddu: mr source' },
		{ key = ',m', config = { sources = { 'marks' } },  desc = 'ddu: marks source' },
		{ key = ',b', config = { sources = { 'buffer' } }, desc = 'ddu: buffer source' },
		{ key = ',f', config = { name = 'node-files' },    desc = 'ddu: file_rec source' },
		{
			key = ',F',
			config = {
				ui = 'filer',
				sources = { 'file' },
				uiParams = {
					filer = {
						displayTree = true,
					}
				}
			},
			desc = 'ddu: file_rec source'
		},
		{ key = '<Space>a', config = { sources = { 'lsp_codeAction' } }, desc = 'ddu: lsp codeAction source' },
		{ key = ',d',       config = { sources = { 'lsp_diagnostic' } }, desc = 'ddu: lsp diagnostics' },
		{ key = ',t',       config = { sources = { 'tab' } },            desc = 'ddu: tabs source' },
		{
			key = ',c',
			config = {
				ui = 'filer',
				sources = { 'file' },
				searchPath = vim.fn.expand('%:p:h'),
				uiParams = {
					filer = {
						displayTree = true,
					},
				}
			},
			desc = 'ddu: current file source'
		},
		-- { key = ',c',       config = { sources = { 'colorscheme' } },    desc = 'ddu: colorscheme source' },
	}

	for _, v in ipairs(res) do
		vim.keymap.set('n', v.key, helper.start(v.config), { silent = true, noremap = true, desc = v.desc })
	end

	-- ファイル検索開始
	-- カーソル上のワードで grep
	vim.keymap.set('n', ',g', function()
		-- FIX: not works
		---@param word string | nil
		local grep = function(word)
			if word == nil then
				return
			end

			helper.start({
				sources = {
					{
						name = 'rg',
						params = {
							input = word,
						},
					},
				},
			})()
		end

		local input = vim.fn.expand('<cword>')
		if string.len(input) <= 2 then
			vim.ui.input({
				prompt = 'Enter word for grep',
			}, grep)
		else
			grep(input)
		end
	end, { silent = true, noremap = true, desc = 'grep files' })

	vim.keymap.set('n', '<space>h', helper.start({ name = 'lsp_callHierarchy' }),
		{ silent = true, noremap = true, desc = 'lsp_callHierarchy/outgoing and incoming calls' })

	vim.keymap.set('n', 'gi', helper.start({ name = 'lsp_implementation' }),
		{ silent = true, noremap = true, desc = 'textDocument/implementation' })

	vim.keymap.set('n', 'gd', helper.start({ name = 'lsp_definition' }),
		{ silent = true, noremap = true, desc = 'textDocument/definition' })

	vim.keymap.set('n', 'gD', helper.start({ name = 'lsp_declaration' }),
		{ silent = true, noremap = true, desc = 'textDocument/declaration' })

	vim.keymap.set('n', '<space>wl', helper.start({ name = 'workspace' }),
		{ silent = true, noremap = true, desc = 'workspaceFolder' })

	vim.keymap.set('n', 'gtd', helper.start({ name = 'lsp_typeDefinition' }),
		{ silent = true, noremap = true, desc = 'textDocument/typeDefinition' })

	vim.keymap.set('n', 'gr',
		helper.start({
			sources = {
				helper.separator('>>Definition<<', '#fc514e'),
				{
					name = 'lsp_definition',
				},
				helper.separator('>>References<<', '#fc514e'),
				{
					name = 'lsp_references',
					params = { includeDeclaration = false },
				},
			},
		})
		, { silent = true, noremap = true, desc = 'textDocument/definition' })
end

return _M
