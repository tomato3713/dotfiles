require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		"go",
		"gotmpl",
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
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			node_decremental = "<S-CR>",
		},
	},
}

-- go template engine
-- local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
-- parser_config.gotmpl = {
-- 	install_info = {
-- 		url = "https://github.com/ngalaiko/tree-sitter-go-template",
-- 		files = { "src/parser.c" }
-- 	},
-- 	filetype = "gotmpl",
-- 	used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" }
-- }

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
