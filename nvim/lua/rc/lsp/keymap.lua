return function()
	-- diagnostics (LSP 不要なのでグローバル設定)
	local opts = { noremap = true, silent = true }
	vim.keymap.set("n", "gs", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[e", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)
	vim.keymap.set("n", "]e", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)
	vim.keymap.set("n", "<Space>q", vim.diagnostic.setloclist, opts)

	-- LSP keymaps (LspAttach でバッファローカルに設定)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufopts = { noremap = true, silent = true, buffer = args.buf }

			-- code reading
			--- 定義情報などを表示する
			vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
			--- 関数の引数の内容とかを表示する
			vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)

			-- code edit
			--- 関数名や変数名をリネーム
			vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "<Space>f", function()
				require("my.utils").keep_cursor(vim.lsp.buf.format)
			end, bufopts)

			-- workspace
			vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
		end,
	})
end
