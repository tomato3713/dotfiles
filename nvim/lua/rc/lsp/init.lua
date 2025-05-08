local setup_keymap = require('rc.lsp.keymap')
local register_servers = require('rc.lsp.register_servers')

-- setup mason
require('mason').setup({
	ui = {
		icons = {
			package_installed = "＊",
			package_pending = "∴",
			package_uninstalled = "×"
		}
	}
})

require("mason-lspconfig").setup {
	automatic_installation = false,
}

register_servers()
setup_keymap()


vim.lsp.set_log_level("OFF")

-- LSPの警告フォーマット
-- ref: https://dev.classmethod.jp/articles/eetann-change-neovim-lsp-diagnostics-format/
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.buf(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.buf(vim.lsp.buf.hover, {
	silent = true,
	border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.buf(vim.lsp.buf.signature_help, {
	silent = true,
	border = "single",
})
vim.diagnostic.config({
	float = {
		border = "single",
		severity_sort = true,
	},
})
