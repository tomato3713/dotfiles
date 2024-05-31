local _M = {}

local ddu_helper = require('rc.helper.ddu')

local function resize()
	local lines = vim.opt.lines:get()
	local columns = vim.opt.columns:get()

	local winHeight = math.max(math.floor(lines / 3), 8)
	local winWidth = math.max(math.floor(columns / 2) - 2, 40)

	local previewHeight = winHeight - 3
	local previewWidth = winWidth

	local winRow, winCol = lines - winHeight - 4, 1
	local previewRow, previewCol = winRow + 3, math.floor(winWidth / 2)

	ddu_helper.patch_global({
		uiParams = {
			ff = {
				winHeight = winHeight,
				winRow = winRow,
				winWidth = winWidth,
				winCol = winCol,
				previewHeight = previewHeight,
				previewRow = previewRow,
				previewWidth = previewWidth,
				previewCol = previewCol,
			},
		},
	})
end

_M.setup = function()
ddu_helper.patch_global({
	ui = 'ff',
	sourceParams = {
		rg = { args = { '--column', '--no-heading', '--color', 'never' } },
	},
	sourceOptions = {
		_ = {
			ignoreCase = true,
			maxItems = 500,
			matchers = {
				'matcher_substring',
			},
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
	},
	filterParams = {
		matcher_substring = { highhtMatched = 'Search' },
	},
	kindOptions = {
		help = { defaultAction = 'open' },
		file = { defaultAction = 'open' },
		lsp = { defaultAction = 'open' },
		lsp_codeAction = { defaultAction = 'apply' },
		colorscheme = { defaultAction = 'set' },
		chooseAction = { defaultAction = 'do' },
		joplin = { defaultAction = 'open' },
		tab = { defaultAction = 'open' },
		action = { defaultAction = 'do' },
	},
	uiParams = {
		ff = {
			prompt = '$ ',
			split = 'floating',
			autoAction = {
				name = 'preview',
			},
			maxDisplayItems = 500,
			startAutoAction = true,
			previewFloating = true,
			previewFloatingBorder = 'single',
			previewSplit = 'vertical',
			floatingBorder = 'single',
			highlights = {
				floatingBorder = 'Verbose',
			},
		},
		filer = {
			statusline = false,
			displayRoot = true,
			displayTree = true,
			split = 'floating',
			floatingBorder = 'single',
			autoAction = {
				name = 'preview',
			},
		},
	},
})

ddu_helper.patch_local('node-files', {
	sources = { 'file_rec' },
	sourceParams = {
		file_rec = {
			ignoredDirectories = { '.git', 'node_modules', 'vendor', '.next', '.vscode', 'tmp' },
		},
	},
})

ddu_helper.patch_local('jp-files', {
	sources = { 'file_rec' },
	sourceOptions = {
		file_rec = {
			matchers = {
				'matcher_kensaku',
			},
		},
	},
})

-- sources from language server
ddu_helper.patch_local('lsp_callHierarchy', {
	sources = {
		ddu_helper.separator('>>callHierarchy/outgoingCalls<<', '#fc514e'),
		{
			name = 'lsp_callHierarchy',
			params = { method = 'callHierarchy/outgoingCalls' },
		},
		ddu_helper.separator('>>callHierarchy/incommingCalls<<', '#5e97ec'),
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

ddu_helper.patch_local('lsp_implementation', {
	sources = {
		{
			name = 'lsp_definition',
			method = 'textDocument/implementation',
		},
	},
})

ddu_helper.patch_local('lsp_declaration', {
	sources = {
		{
			name = 'lsp_definition',
			method = 'textDocument/declaration',
		},
	},
})

ddu_helper.patch_local('lsp_typeDefinition', {
	sources = {
		{
			name = 'lsp_definition',
			method = 'textDocument/typeDefinition',
		},
	},
})

ddu_helper.patch_local('lsp_definition', {
	sources = {
		{
			name = 'lsp_definition',
			method = 'textDocument/definition',
		},
	},
})

resize()

require('my.utils').nvim_create_autocmd('VimResized', {
	callback = resize,
	desc = 'calculate ddu window size',
})

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
	{ key = ',c',       config = { sources = { 'colorscheme' } },    desc = 'ddu: colorscheme source' },
	{ key = '<Space>a', config = { sources = { 'lsp_codeAction' } }, desc = 'ddu: lsp codeAction source' },
	{ key = ',d',       config = { sources = { 'lsp_diagnostic' } }, desc = 'ddu: lsp diagnostics' },
	{ key = ',t',       config = { sources = { 'tab' } },            desc = 'ddu: tabs source' },
}

for _, v in ipairs(res) do
	vim.keymap.set('n', v.key, ddu_helper.start(v.config), { silent = true, noremap = true, desc = v.desc })
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

		ddu_helper.start({
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

vim.keymap.set('n', '<space>h', ddu_helper.start({ name = 'lsp_callHierarchy' }),
	{ silent = true, noremap = true, desc = 'lsp_callHierarchy/outgoing and incomming calls' })

vim.keymap.set('n', 'gi', ddu_helper.start({ name = 'lsp_implementation' }),
	{ silent = true, noremap = true, desc = 'textDocument/implementation' })

vim.keymap.set('n', 'gD', ddu_helper.start({ name = 'lsp_declaration' }),
	{ silent = true, noremap = true, desc = 'textDocument/declaration' })

vim.keymap.set('n', 'gtd', ddu_helper.start({ name = 'lsp_typeDefinition' }),
	{ silent = true, noremap = true, desc = 'textDocument/typeDefinition' })

vim.keymap.set('n', 'gd', ddu_helper.start({ name = 'lsp_definition' }),
	{ silent = true, noremap = true, desc = 'textDocument/definition' })

vim.keymap.set('n', 'gr',
	ddu_helper.start({
		sources = {
			ddu_helper.separator('>>Definition<<', '#fc514e'),
			{
				name = 'lsp_definition',
			},
			ddu_helper.separator('>>References<<', '#fc514e'),
			{
				name = 'lsp_references',
				params = { includeDeclaration = false },
			},
		},
	})
	, { silent = true, noremap = true, desc = 'textDocument/definition' })

if vim.env.JOPLIN_TOKEN ~= nil then
	ddu_helper.patch_global('sourceParams', {
		joplin = { token = vim.env.JOPLIN_TOKEN, fullPath = true },
		joplin_tree = { token = vim.env.JOPLIN_TOKEN },
	})

	ddu_helper.patch_local('joplin', {
		sourceOptions = {
			joplin = { columns = { 'joplin' } },
			joplin_tree = { columns = { 'joplin' } },
		},
		columnParams = {
			joplin = {
				collapsedIcon = '',
				expandedIcon = '',
				noteIcon = '',
				checkedIcon = '',
				uncheckedIcon = '',
			},
		},
	})

	local joplin_mapping = {
		{
			key = ',j',
			desc = 'ddu: joplin source',
			config = {
				name = 'joplin',
				sources = { 'joplin' },
			},
		},
		{
			key = ',J',
			config = {
				name = 'joplin',
				ui = 'filer',
				sources = { 'joplin_tree' },
			},
			desc = 'ddu: joplin source'
		},
	}

	for _, v in ipairs(joplin_mapping) do
		vim.keymap.set('n', v.key, ddu_helper.start(v.config),
			{ silent = true, noremap = true, desc = v.desc })
	end

	vim.keymap.set('n', ',k', function()
		local word = vim.fn.expand('<cword>')
		ddu_helper.start({
			name = 'joplin',
			sources = {
				{
					name = 'joplin',
					params = {
						input = word,
					},
				},
			},
		})
	end, { silent = true, noremap = true, desc = 'grep Joplin notes and todos' })
end
end

return _M
