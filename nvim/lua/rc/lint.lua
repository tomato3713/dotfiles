require('lint').linters.perlcritic = require('rc.perlcritic')

require('lint').linters_by_ft = {
	javascript = {
		'eslint_d',
	},
	typescript = {
		'eslint_d',
	},
	javascriptreact = {
		'eslint_d',
	},
	typescriptreact = {
		'eslint_d',
	},
	jsx = {
		'eslint_d',
	},
	tsx = {
		'eslint_d',
	},
	json = {
		'eslint_d',
	},
	markdown = {
		'markdownlint',
	},
	go = {
		'golangcilint',
	},
	perl = {
		'perlcritic',
	},
}

require("lint").try_lint()

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
		if vim.fn.filereadable(".vale.ini") > 0 then
			require("lint").try_lint({ "vale" })
		end
	end,
})
