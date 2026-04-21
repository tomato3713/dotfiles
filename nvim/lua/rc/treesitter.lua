-- Parser installation (new API; replaces ensure_installed)
local installed = require('nvim-treesitter.config').get_installed()
local parsers = { "go", "gotmpl", "tsx", "css", "lua", "perl", "markdown", "toml", "yaml", "json" }
local to_install = vim.iter(parsers)
	:filter(function(p) return not vim.tbl_contains(installed, p) end)
	:totable()
if #to_install > 0 then
	require('nvim-treesitter').install(to_install)
end

-- Highlighting and indentation via Neovim built-in treesitter (0.12+)
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		pcall(vim.treesitter.start)
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- Filetype detection
vim.filetype.add({
	extension = {
		gotmpl = 'gotmpl',
	},
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.tmpl" },
	callback = function()
		vim.bo.filetype = "gotmpl"
	end,
})
