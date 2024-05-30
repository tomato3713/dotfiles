local ddc_helper = require("rc.helper.ddc")

ddc_helper.patch_global('ui', "pum")
local autoCompleteEvents = {
	"InsertEnter",
	"TextChangedI",
	"TextChangedP",
	"TextChangedT",
}
ddc_helper.patch_global('autoCompleteEvents', autoCompleteEvents)

ddc_helper.patch_global('sources', {
	"copilot",
	"vsnip", "lsp",
	"around", "file",
})

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
ddc_helper.patch_global('sourceOptions', {
	cmdline = {
		mark = 'Ex',
	},
	["shell-native"] = {
		-- ref: https://blog.atusy.net/2023/12/20/ddc-fish-alias-completion/
		mark = 'Ex',
		matchers = { "matcher_head" },
		isVolatile = true,
		minAutoCompleteLength = 0,
		minKeywordLength = 0,
		-- コマンドラインが `!`、`Make `、`Gin `、`GinBuffer `のいずれかで始まる場合のみ有効
		enabledIf = string.format(
			[[getcmdline() =~# "^\\(%s\\)" ? v:true : v:false]],
			table.concat({ "!", "Make ", "Gin ", "GinBuffer " }, [[\\|]])
		),
	},
	["cmdline-history"] = {
		mark = 'Hist',
	},
	["input"] = {
		mark = 'input',
		matchers = {},
		minAutoCompleteLength = 0,
		forceCompletionPattern = { [['\S/\S*|\.\w*']] },
		isVolatile = true,
	},
})
ddc_helper.patch_global('sourceParams', {
	["shell-native"] = {
		shell = 'zsh',
	},
})
ddc_helper.patch_global('cmdlineSources', {
	[':'] = { 'cmdline', 'shell-native', 'cmdline-history', 'shell-native', 'file' },
	['/'] = { 'around' },
	['?'] = { 'around' },
	['='] = { 'input' },
})

local commandlinePost = function()
	ddc_helper.patch_global("autoCompleteEvents", autoCompleteEvents)
	ddc_helper.enable_cmdline_completion()
end

local commandLinePre = function(ch)
	ddc_helper.patch_global("autoCompleteEvents", {
		"CmdlineEnter",
		"CmdlineChanged",
	})

	require('rc.utils').nvim_create_autocmd("User", {
		pattern = "DDCCmdlineLeave",
		callback = function()
			commandlinePost()
		end,
		once = true,
	})

	ddc_helper.enable_cmdline_completion()
	vim.fn.feedkeys(vim.api.nvim_replace_termcodes(ch, true, true, true), "n")
end
vim.keymap.set("n", ":", function()
	commandLinePre(":")
end, { noremap = true, silent = true })
vim.keymap.set("n", "/", function()
	commandLinePre("/")
end, { noremap = true, silent = true })
vim.keymap.set("n", "?", function()
	commandLinePre("?")
end, { noremap = true, silent = true })

ddc_helper.enable()
