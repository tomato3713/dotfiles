require("nvim-treesitter.configs").setup({
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
})
