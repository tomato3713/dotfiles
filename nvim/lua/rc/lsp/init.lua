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

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

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
