vim.fn['ddc#custom#patch_global']({
	ui = 'pum',
	sources = { 'skkeleton', 'vsnip', 'lsp', 'around', 'file' },
	autoCompleteEvents = {
		'InsertEnter',
		'TextChangedI',
		'TextChangedP',
		'CmdlineChanged',
		'CmdlineEnter',
		'TextChangedT' },
	backspaceCompletion = true,
	sourceOptions = {
		_ = {
			ignoreCase = true,
			matchers = { 'matcher_fuzzy' },
			sorters = { 'sorter_fuzzy' },
			converters = { 'converter_fuzzy' },
		},
		around = {
			mark = 'Around',
		},
		lsp = {
			mark = 'LS',
			keywordPattern = '\\k+',
		},
		vsnip = {
			mark = 'Snip',
		},
		skkeleton = {
			mark = 'SKK',
			matchers = { 'skkeleton' },
			minAutoCompleteLength = 1,
			isVolatile = true,
		},
		file = {
			mark = 'File',
			forceCompletionPattern = "\\S/\\S*",
			isVolatile = true,
		},
		cmdline = {
			mark = 'Cmd',
		},
		["cmdline-history"] = {
			mark = 'Hist',
		},
		["shell-native"] = {
			mark = 'Sh',
		},
		["shell-history"] = {
			mark = 'Hist',
		},
	},
	sourceParams = {
		lsp = {
			snippetEngine = vim.fn['denops#callback#register'](
				function(body) vim.fn['vsnip#anonymous'](body) end
			),
			enableResolveItem = true,
			enableAdditionalTextEdit = true,
			confirmBehavior = 'replace',
		},
		-- TODO: windows support
		deol = {
			command = { 'zsh' },
		},
		["shell-native"] = {
			shell = 'zsh',
		},
	},
	cmdlineSources = {
		[':'] = { 'cmdline', 'file' },
	},
})

vim.keymap.set({ 'i', 'c' }, '<C-l>', vim.fn['ddc#map#manual_complete'], { silent = true })

-- terminal completion
vim.fn['ddc#enable_terminal_completion']()
-- For deol buffer.
vim.fn['ddc#custom#patch_filetype']({ 'deol', 'zsh', 'deol-edit' }, {
	specialBufferCompletion = true,
	sources = { 'shell-native', 'shell-history', 'around' },
	sourceOptions = {
		_ = {
			keywordPattern = '[0-9a-zA-Z_./#:-]*',
		},
	},
})

-- commandline completion
vim.keymap.set({ 'n', 'x' }, ':', '<Cmd>call ddc#enable_cmdline_completion()<CR>:')

vim.fn['ddc#enable']()
