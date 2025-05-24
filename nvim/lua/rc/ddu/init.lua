local _M = {}

local helper = require('rc.helper.ddu')
local ff = require('rc.ddu.ui-ff')
local filer = require('rc.ddu.ui-filer')
local source_lsp = require('rc.ddu.source.lsp')

local function setup_ui_params()
	helper.patch_global('ui', 'ff')
	helper.patch_global('uiParams', {
		ff = ff.ui_params,
		filer = filer.ui_params,
	})
end


-- setup language server sources
local function setup_lsp_sources()
	helper.patch_global('kindOptions', {
		lsp = { defaultAction = 'open' },
		lsp_codeAction = { defaultAction = 'apply' },
	})

	for _, v in pairs(source_lsp) do
		helper.patch_local('lsp_' .. v.name, v.opt)
	end
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

	helper.patch_local('filer', {
		ui = 'filer',
		sources = { 'file' },
		uiParams = {
			filer = {
				displayTree = true,
			}
		}
	})

	setup_lsp_sources()
end



-- mappings
_M.set_keymap = function()
	local res = {
		{ key = ',f',        config = { name = 'node-files' },            desc = 'ddu: file_rec source' },
		{ key = ',F',        config = { name = 'filer', },                desc = 'ddu: file_rec source' },
		{ key = ',h',        config = { sources = { 'help' }, },          desc = 'ddu: help tags source' },
		{ key = ',o',        config = { sources = { 'mr' } },             desc = 'ddu: mr source' },
		{ key = ',m',        config = { sources = { 'marks' } },          desc = 'ddu: marks source' },
		{ key = ',b',        config = { sources = { 'buffer' } },         desc = 'ddu: buffer source' },
		{ key = ',t',        config = { sources = { 'tab' } },            desc = 'ddu: tabs source' },
		{ key = ',c',        config = { sources = { 'colorscheme' } },    desc = 'ddu: colorscheme source' },

		-- lsp
		{ key = '<Space>a',  config = { sources = { 'lsp_codeAction' } }, desc = 'ddu: lsp codeAction source' },
		{ key = ',d',        config = { sources = { 'lsp_diagnostic' } }, desc = 'ddu: lsp diagnostics' },
		{ key = '<Space>h',  config = { name = 'lsp_callHierarchy' },     desc = 'ddu: lsp_callHierarchy/outgoing and incoming calls' },
		{ key = 'gi',        config = { name = 'lsp_implementation' },    desc = 'textDocument/implementation' },
		{ key = 'gd',        config = { name = 'lsp_definition' },        desc = 'textDocument/definition' },
		{ key = 'gD',        config = { name = 'lsp_declaration' },       desc = 'textDocument/declaration' },
		{ key = '<space>wl', config = { name = 'workspace' },             desc = 'workspaceFolder' },
		{ key = 'gtd',       config = { name = 'lsp_typeDefinition' },    desc = 'textDocument/typeDefinition' },
		{ key = 'gr',        config = { name = 'lsp_references' },        desc = 'references' },
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
end

return _M
