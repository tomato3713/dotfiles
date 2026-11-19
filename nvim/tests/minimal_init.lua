-- テストはユーザー設定やプラグインに左右されないよう、この nvim/ ディレクトリと mini.nvim だけを読み込む
-- 実行: nvim/ で `make test`
vim.opt.rtp:prepend(vim.fn.getcwd())

-- dein で導入済みならそれを使い、なければ取得する (CI など dein が無い環境でも動かすため)
local mini_path = vim.fn.expand('~/.cache/dein/repos/github.com/nvim-mini/mini.nvim')
if vim.fn.isdirectory(mini_path) == 0 then
	mini_path = vim.fn.getcwd() .. '/tests/.deps/mini.nvim'
	if vim.fn.isdirectory(mini_path) == 0 then
		vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/nvim-mini/mini.nvim', mini_path })
	end
end
vim.opt.rtp:append(mini_path)

-- 子プロセスでは不要。テストを走らせる親プロセスでだけ有効にする
if #vim.api.nvim_list_uis() == 0 then
	require('mini.test').setup()
end
