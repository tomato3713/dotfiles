local setup_keymap = require('rc.lsp.keymap')
local register_servers = require('rc.lsp.register_servers')

-- setup mason
require('mason').setup()

require("mason-lspconfig").setup {
	automatic_installation = false,
}

local names = require('mason-lspconfig').get_available_servers()

register_servers(names)
setup_keymap()


vim.lsp.log.set_level("OFF")

vim.lsp.config('*', {
	handlers = {
		['textDocument/signatureHelp'] = function(err, result, ctx, config)
			vim.lsp.handlers.signature_help(err, result, ctx, vim.tbl_extend('keep', config or {}, {
				silent = true,
				border = "single",
			}))
		end,
	},
})
vim.diagnostic.config({
	float = {
		border = "single",
		severity_sort = true,
	},
	virtual_text = {
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})
