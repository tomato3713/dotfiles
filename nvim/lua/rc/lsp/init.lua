require('mason').setup()
-- mason でインストール済みのサーバーだけを vim.lsp.enable() する (automatic_enable はデフォルト有効)。
-- get_available_servers() はレジストリ上の全サーバーを返すため、未インストールのものまで enable されてしまう
require('mason-lspconfig').setup()

require('rc.lsp.keymap')()

vim.lsp.log.set_level('OFF')

-- 補完は nvim-cmp を使わず Neovim 標準の LSP 補完に一本化している
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.diagnostic.config({
	float = {
		border = 'single',
		severity_sort = true,
	},
	virtual_text = {
		format = function(diagnostic)
			-- code を返さないサーバーもあるため、存在するときだけ付与する
			if diagnostic.code then
				return string.format('%s (%s: %s)', diagnostic.message, diagnostic.source, diagnostic.code)
			end
			return string.format('%s (%s)', diagnostic.message, diagnostic.source)
		end,
	},
})
