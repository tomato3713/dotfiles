local nvim_lsp = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')
local utils = require('rc.utils')
require('neodev').setup()

-- LSPの警告フォーマット
-- ref: https://dev.classmethod.jp/articles/eetann-change-neovim-lsp-diagnostics-format/
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		format = function(diagnostic)
			return string.format('%s (%s: %s)', diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
	silent = true,
	border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.signature_help, {
		silent = true,
		border = "single"
	}
)
vim.diagnostic.config {
	float = { border = "single" },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<Space>df', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Space>f', require('rc.utils').keep_cursor(vim.lsp.buf.format), { noremap = true, silent = true })

local on_attach = function(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- code reading
	-- show information at cursor
	--- 定義情報などを表示する
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	--- 関数の引数の内容とかを表示する
	vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, bufopts)
	--- カーソル行のエラーを表示
	vim.keymap.set('n', 'gs', vim.diagnostic.open_float, bufopts)

	-- code walking
	--- 前のエラーに移動
	vim.keymap.set('n', 'g[', '<cmd>lua vim.lsp.buf.diagnostic.show_prev()<CR>', bufopts)
	--- 次のエラーに移動
	vim.keymap.set('n', 'g]', '<cmd>lua vim.lsp.buf.diagnostic.show_next()<CR>', bufopts)

	-- code edit
	--- 関数名や変数名をリネーム
	vim.keymap.set('n', '<Space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)
	--- フォーマット実行
	-- vim.keymap.set('n', '<Space>f', '<cmd>lua vim.lsp.buf.format( { async = true } )<CR>',           bufopts)

	-- workspace
	--- ワークスペース一覧を表示
	vim.keymap.set("n", "<space>wl", '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
	--- ワークスペースにフォルダを追加する
	vim.keymap.set("n", "<space>wa", '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
	vim.keymap.set("n", "<space>wr", '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')

	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = bufnr,
			callback = function()
				if utils.contains({ 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }, vim.bo.filetype) then
				end
				require('rc.utils').keep_cursor(vim.lsp.buf.format)
			end
		})
	end
end

mason_lspconfig.setup_handlers({
	function(server_name)
		-- tsserverとdenolsを出し分ける
		local node_root_dir = nvim_lsp.util.root_pattern("package.json")
		local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

		local opts = {}
		if server_name == "tsserver" then
			if not is_node_repo then return end
			opts.root_dir = node_root_dir
		elseif server_name == "eslint" then
			if not is_node_repo then return end
			opts.root_dir = node_root_dir
		elseif server_name == "denols" then
			if is_node_repo then return end
			opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc", "deps.ts",
				"import_map.json", "denops")
			opts.init_options = {
				lint = true,
				unstable = true,
				suggest = {
					imports = {
						hosts = {
							["https://deno.land"] = true,
							["https://cdn.nest.land"] = true,
							["https://crux.land"] = true
						}
					}
				}
			}
		end

		opts.on_attach = on_attach

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		opts.capabilities = capabilities

		nvim_lsp[server_name].setup(opts)
	end
})
