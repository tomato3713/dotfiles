local ddc_helper = require("rc.helper.ddc")
local utils = require("rc.utils")

ddc_helper.patch_global('ui', "pum")

ddc_helper.patch_global('autoCompleteEvents', {
	"InsertEnter",
	"TextChangedI",
	"TextChangedP",
	"CmdlineChanged",
	"TextChangedT",
})

ddc_helper.patch_global('sources', { "copilot", "vsnip", "lsp", "around", "file" })

ddc_helper.patch_global({
	backspaceCompletion = true,
	specialBufferCompletion = true,
	sourceOptions = {
		_ = {
			ignoreCase = true,
			matchers = { "matcher_fuzzy" },
			sorters = { "sorter_fuzzy" },
			converters = { "converter_fuzzy" },
		},
		around = {
			mark = "Around",
		},
		lsp = {
			mark = "LS",
			keywordPattern = "\\k+",
			dup = "keep",
		},
		vsnip = {
			mark = "Snip",
		},
		skkeleton = {
			mark = "SKK",
			matchers = { "skkeleton" },
			minAutoCompleteLength = 1,
			isVolatile = true,
			sorters = {},
			converters = {},
		},
		file = {
			mark = "File",
			forceCompletionPattern = "\\S/\\S*",
			isVolatile = true,
		},
		copilot = {
			mark = "copilot",
			matchers = {},
			minAutoCompleteLength = 1,
			isVolatile = true,
		},
	},
	sourceParams = {
		lsp = {
			snippetEngine = vim.fn["denops#callback#register"](
				function(body) vim.fn["vsnip#anonymous"](body) end
			),
			enableResolveItem = true,
			enableAdditionalTextEdit = true,
			confirmBehavior = "replace",
		},
	},
})

-- commandline completion
ddc_helper.patch_global('cmdlineSources', {
	[':'] = { 'cmdline', 'cmdline-history', 'file' },
	['/'] = { 'around' },
	['?'] = { 'around' },
	['='] = { 'input' },
})
ddc_helper.patch_global('sourceOptions', {
	cmdline = {
		mark = '[Cmd]',
		maxItems = 5,
	},
	["cmdline-history"] = {
		mark = '[Hist]',
		maxItems = 5,
	},
	["input"] = {
		mark = '[input]',
		matchers = {},
		minAutoCompleteLength = 0,
		forceCompletionPattern = { [['\S/\S*|\.\w*']] },
		isVolatile = true,
	},
})

utils.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		ddc_helper.enable_cmdline_completion()
	end,
	desc = 'enable ddc.vim cmdline completion',
})

-- terminal completion
ddc_helper.patch_global('sourceOptions', {
	["shell-native"] = {
		mark = '[Shell]',
		isVolatile = true,
		keywordPattern = "[0-9a-zA-Z_./#:-]*",
		minAutoCompleteLength = 1,
		forceCompletionPattern = "\\S/\\S*",
	},
	-- ["shell-history"] = {
	-- 	mark = 'Hist',
	-- 	keywordPattern = '[0-9a-zA-Z_./#:-]*',
	-- },
})

ddc_helper.patch_global('sourceParams', {
	["shell-native"] = {
		shell = 'zsh',
	},
})

utils.nvim_create_autocmd("TermEnter", {
	callback = function()
		ddc_helper.patch_global('sources', { "shell-native", "file", "around" })
	end,
})

utils.nvim_create_autocmd("TermLeave", {
	callback = function()
		ddc_helper.remove_buffer('sources')
	end,
})
ddc_helper.enable_terminal_completion()

ddc_helper.enable()
