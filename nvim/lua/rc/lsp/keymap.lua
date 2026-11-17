return function()
	-- diagnostics (LSP 不要なのでグローバル設定)
	local opts = { silent = true }
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
			local bufopts = { silent = true, buffer = args.buf }

			-- code reading
			--- 定義情報などを表示する
			-- Neovim 0.11 以降、hover/signature_help は handler を経由しないため border は引数で渡す
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ border = "single" })
			end, bufopts)
			--- 関数の引数の内容とかを表示する
			vim.keymap.set("n", "<c-k>", function()
				vim.lsp.buf.signature_help({ border = "single" })
			end, bufopts)

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
