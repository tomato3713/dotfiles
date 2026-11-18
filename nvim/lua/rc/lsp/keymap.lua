return function()
	-- diagnostics (LSP 不要なのでグローバル設定)
	-- float は gs が mini.splitjoin と衝突するため、標準の <C-w>d で開く
	local opts = { silent = true }
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
			local bufopts = { silent = true, buffer = args.buf }

			-- code reading
			-- hover は Neovim 標準の K を使う。枠線は winborder で付く
			--- 関数の引数の内容とかを表示する
			vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)

			-- code edit
			--- 関数名や変数名をリネーム
			vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, bufopts)
			-- keep_cursor() は関数を返すので、そのまま rhs に渡す
			vim.keymap.set("n", "<Space>f", require("my.utils").keep_cursor(vim.lsp.buf.format), bufopts)

			-- workspace
			vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
		end,
	})
end
