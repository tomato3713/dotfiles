local ddu_helper = require('rc.helper.ddu')

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
			startFilter = true,
			split = 'floating',
			autoAction = {
				name = 'preview',
			},
			maxDisplayItems = 500,
			startAutoAction = true,
			previewFloating = true,
			previewFloatingBorder = 'double',
			previewSplit = 'vertical',
			floatingBorder = 'single',
			highlights = {
				floatingBorder = 'Verbose',
			},
		},
		filer = {
			statusline = false,
			displayRoot = false,
			displayTree = true,
			split = 'floating',
			floatingBorder = 'single',
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

local function resize()
	local lines = vim.opt.lines:get()
	local height, row = math.floor(lines * 0.2), math.floor(lines * 0.1)
	local previewHeight = math.floor(lines - height - row - 2 - 5)
	local columns = vim.opt.columns:get()
	local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
	local previewWidth = width

	ddu_helper.patch_global({
		uiParams = {
			ff = {
				winHeight = height,
				winRow = row,
				winWidth = width,
				winCol = col,
				previewHeight = previewHeight,
				previewRow = row + height + 2,
				previewWidth = previewWidth,
				previewCol = col,
			},
		},
	})
end
resize()

require('rc.utils').nvim_create_autocmd('VimResized', {
	callback = resize,
	desc = 'calculate ddu window size',
})

-- mappings
local res = {
	{ key = ',h',       config = { sources = { 'help' } },           desc = 'ddu: help tags source' },
	{ key = ',o',       config = { sources = { 'mr' } },             desc = 'ddu: mr source' },
	{ key = ',m',       config = { sources = { 'marks' } },          desc = 'ddu: marks source' },
	{ key = ',b',       config = { sources = { 'buffer' } },         desc = 'ddu: buffer source' },
	{ key = ',f',       config = { name = 'node-files' },            desc = 'ddu: file_rec source' },
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
	local grep = function(word)
		ddu_helper.start({
			name = 'grep',
			sources = {
				{
					name = 'rg',
					params = {
						input = word,
					},
				},
			},
		})
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

-- sources from language server
vim.keymap.set('n', '<space>h', function()
	ddu_helper.start({
		name = 'lsp_callHierarchy',
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
	})
end, { silent = true, noremap = true, desc = 'lsp_callHierarchy/outgoing and incomming calls' })

vim.keymap.set('n', 'gi', function()
	ddu_helper.start({
		name = 'lsp',
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/implementation',
			},
		},
	})
end, { silent = true, noremap = true, desc = 'textDocument/implementation' })

vim.keymap.set('n', 'gD', function()
	ddu_helper.start({
		name = 'lsp',
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/declaration',
			},
		},
	})
end, { silent = true, noremap = true, desc = 'textDocument/declaration' })

vim.keymap.set('n', 'gtd', function()
	ddu_helper.start({
		name = 'lsp',
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/typeDefinition',
			},
		},
	})
end, { silent = true, noremap = true, desc = 'textDocument/typeDefinition' })

vim.keymap.set('n', 'gd', function()
	ddu_helper.start({
		name = 'lsp',
		sources = {
			{
				name = 'lsp_definition',
				method = 'textDocument/definition',
			},
		},
	})
end, { silent = true, noremap = true, desc = 'textDocument/definition' })

vim.keymap.set('n', 'gr', function()
	ddu_helper.start({
		name = 'lsp',
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
end, { silent = true, noremap = true, desc = 'textDocument/definition' })

if vim.env.JOPLIN_TOKEN ~= nil then
	ddu_helper.patch_local('joplin', {
		sourceParams = {
			joplin = { token = vim.env.JOPLIN_TOKEN, fullPath = true },
			joplin_tree = { token = vim.env.JOPLIN_TOKEN },
		},
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
		vim.keymap.set('n', v.key, ddu_helper.start(v.config or {}),
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
