return function()
	vim.lsp.config('*', {
		capabilities = require('cmp_nvim_lsp').default_capabilities(),
	})

	local names = {
		'gopls',
		'lua_ls',
		'terraformls',
		'perlnavigator',
		'tsserver',
		'eslint',
		'denols',
	}
	vim.lsp.enable(names)
end
