local M = {}

-- https://github.com/uga-rosa/dotfiles/blob/92a4de22aa1722d3285b6ffd39c50cbf3925272c/nvim/lua/rc/helper/ddc.lua#L19
function M.patch_buffer(...)
	vim.fn["ddc#custom#patch_buffer"](...)
end

---@param ... string
function M.remove_buffer(...)
	local options = vim.fn["ddc#custom#get_buffer"]()
	local root = options
	local keys = { ... }
	local last_key = table.remove(keys)
	for _, key in ipairs(keys) do
		options = options[key]
	end
	options[last_key] = nil
	if vim.tbl_isempty(root) then
		root = vim.empty_dict()
	end
	vim.fn["ddc#custom#set_buffer"](root)
end

vim.fn['ddc#custom#patch_global']({
	ui = 'pum',
	sources = { 'copilot', 'vsnip', 'lsp', 'around', 'file' },
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
		copilot = {
			mark = 'copilot',
			matchers = {},
			minAutoCompleteLength = 0,
			isVolatile = true,
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

return M
