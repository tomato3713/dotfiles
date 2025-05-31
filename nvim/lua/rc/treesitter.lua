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
	textobjects = {
		select = {
			enable = true,
			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,
			keymaps = {
				["ab"] = {
					query = "@block.outer",
					desc = "Select outer part of a block region"
				},
				["ib"] = {
					query = "@block.inner",
					desc = "Select inner part of a block region"
				},

				["ai"] = {
					query = "@conditional.outer",
					desc = "Select outer part of a conditional"
				},
				["ii"] = {
					query = "@conditional.inner",
					desc = "Select inner part of a conditional"
				},

				["al"] = {
					query = "@loop.outer",
					desc = "Select outer part of a loop"
				},
				["il"] = {
					query = "@loop.inner",
					desc = "Select inner part of a loop"
				},

				["af"] = {
					query = "@function.outer",
					desc = "Select outer part of a method/function definition",
				},
				["if"] = {
					query = "@function.inner",
					desc = "Select inner part of a method/function definition",
				},

			},
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
