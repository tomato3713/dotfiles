return function()
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<Space>df", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[e", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]e", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>f",
	function() require("my.utils").keep_cursor(vim.lsp.buf.format) end,
	{ noremap = true, silent = true })


	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- code reading
	-- show information at cursor
	--- 定義情報などを表示する
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	--- 関数の引数の内容とかを表示する
	vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)
	--- カーソル行のエラーを表示
	vim.keymap.set("n", "gs", vim.diagnostic.open_float, bufopts)

	-- code walking
	--- 前のエラーに移動
	vim.keymap.set("n", "g[", "<cmd>:lua vim.lsp.buf.diagnostic.show_prev()<CR>", bufopts)
	--- 次のエラーに移動
	vim.keymap.set("n", "g]", "<cmd>:lua vim.lsp.buf.diagnostic.show_next()<CR>", bufopts)

	-- code edit
	--- 関数名や変数名をリネーム
	vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, bufopts)

	-- workspace
	--- ワークスペース一覧を表示
	-- vim.keymap.set("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
	--- ワークスペースにフォルダを追加する
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder)
end
