require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		"go",
		"tsx", "css",
		"lua",
		"perl",
		"markdown", "toml", "yaml", "json",
	},
	auto_install = false,
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "vim" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	context_commentstring = {
		enable_autocmd = false,
	},
}
