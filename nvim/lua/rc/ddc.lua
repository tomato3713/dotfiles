local ddc_helper = require("rc.helper.ddc")
local utils = require("rc.utils")

ddc_helper.patch_global('ui', "pum")

ddc_helper.patch_global('autoCompleteEvents', {
	"InsertEnter",
	"TextChangedI",
	"TextChangedP",
	"TextChangedT",
	"CmdlineChanged",
})

ddc_helper.patch_global({
	sources = { "copilot", "vsnip", "lsp", "around", "file" },
	backspaceCompletion = true,
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
		},
		vsnip = {
			mark = "Snip",
		},
		skkeleton = {
			mark = "SKK",
			matchers = { "skkeleton" },
			minAutoCompleteLength = 1,
			isVolatile = true,
		},
		file = {
			mark = "File",
			forceCompletionPattern = "\\S/\\S*",
			isVolatile = true,
		},
		copilot = {
			mark = "copilot",
			matchers = {},
			minAutoCompleteLength = 0,
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

vim.keymap.set({ 'i', 'c' }, '<C-l>', vim.fn['ddc#map#manual_complete'], { silent = true })

-- commandline completion
ddc_helper.patch_global({
	backspaceCompletion = true,
	cmdlineSources = {
		[':'] = { 'cmdline-history', 'cmdline', 'file' },
	},
	sourceOptions = {
		cmdline = {
			mark = 'Cmd',
			maxItems = 5,
		},
		["cmdline-history"] = {
			mark = 'Hist',
			maxItems = 5,
		},
	},
})

utils.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		ddc_helper.enable_cmdline_completion()
	end,
	desc = 'enable ddc.vim cmdline completion',
})

-- terminal completion
-- vim.fn['ddc#custom#patch_filetype']({ 'zsh' }, {
-- 	ui = 'pum',
-- 	sources = { 'shell-native', 'file', 'shell-history' },
-- 	specialBufferCompletion = true,
-- 	sourceOptions = {
-- 		_ = {
-- 			keywordPattern = '[0-9a-zA-Z_./#:-]*',
-- 		},
-- 		["shell-native"] = {
-- 			mark = 'Sh',
-- 		},
-- 		-- ["shell-history"] = {
-- 		-- 	mark = 'Hist',
-- 		-- },
-- 	},
-- 	sourceParams = {
-- 		["shell-native"] = {
-- 			shell = 'zsh',
-- 		},
-- 	},
-- })
-- ddc_helper.enable_terminal_completion()

ddc_helper.enable()
