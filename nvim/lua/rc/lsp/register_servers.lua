return function(names)
	vim.lsp.config('*', {
		capabilities = require('cmp_nvim_lsp').default_capabilities(),
	})

	vim.lsp.enable(names)
end
