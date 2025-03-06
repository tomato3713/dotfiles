local helper = require("rc.helper.ddc")

helper.patch_global('ui', "pum")

local cmdline = require('rc.ddc.source.cmdline')

local autoCompleteEvents = {
	"InsertEnter",
	"TextChangedI",
	"TextChangedP",
	"TextChangedT",
}
helper.patch_global('autoCompleteEvents', autoCompleteEvents)

helper.patch_global('sources', {
	"copilot",
	"vsnip", "lsp",
	"around", "file",
})

helper.patch_global({
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
		line = {
			mark = "line",
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
			matchers = {},
			sorters = {},
			converters = {},
			isVolatile = true,
			minAutoCompleteLength = 1,
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
			-- isVolatile = true,
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
helper.patch_global('sourceOptions', {
	cmdline = {
		mark = 'Ex',
	},
	["shell_native"] = {
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
	["cmdline_history"] = {
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
helper.patch_global('sourceParams', {
	["shell_native"] = {
		shell = 'zsh',
	},
})

helper.patch_global('cmdlineSources', {
	[':'] = cmdline.current(),
	['/'] = { 'around', 'line' },
	['?'] = { 'around', 'line' },
	['='] = { 'input' },
})

local commandlinePost = function()
	helper.patch_global("autoCompleteEvents", autoCompleteEvents)
	helper.enable_cmdline_completion()
end

local commandLinePre = function(ch)
	helper.patch_global("autoCompleteEvents", {
		"CmdlineChanged",
	})

	require('my.utils').nvim_create_autocmd("User", {
		pattern = "DDCCmdlineLeave",
		callback = function()
			commandlinePost()
		end,
		once = true,
	})

	helper.enable_cmdline_completion()
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

vim.keymap.set("c", "<C-s>", function()
	helper.patch_buffer('cmdlineSources', {
		[':'] = cmdline.next(),
	})

	require('my.utils').nvim_create_autocmd("User", {
		pattern = "DDCCmdlineLeave",
		callback = function()
			cmdline.reset()
			helper.patch_buffer('cmdlineSources', {
				[':'] = cmdline.current(),
			})
		end,
		once = true,
	})
end, { expr = true, noremap = true, silent = true })

helper.enable()
