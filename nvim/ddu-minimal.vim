set wildmode=full

" --- add runtimepath ---
set runtimepath+=~/repos/github.com/vim-denops/denops.vim

" --- load plugins ---
" テスト対象のPluginをロードする
" set runtimepath+=~/path/to/plugin

source ~/repos/github.com/vim-denops/denops.vim/plugin/denops.vim
set runtimepath+=~/repos/github.com/Shougo/ddu.vim
set runtimepath+=~/repos/github.com/Shougo/ddu-ui-ff
set runtimepath+=~/repos/github.com/Shougo/ddu-source-file
set runtimepath+=~/repos/github.com/tomato3713/ddu-kind-file

" --- 追加設定 ---
" Vimのファイルタイプ検出,ファイルタイププラグインとインデントプラグインをオンにする設定
filetype plugin indent on

" --- denopsの設定 ---
" Denoの起動時型チェックを有効化(開発が安定したら明示指定を削除する
" let g:denops#server#service#deno_args = [
"       \ '-q',
"       \ '-A',
"       \ ]

nnoremap ,t <Cmd>call ddu#start(#{
	\ ui: 'ff',
	\ name: 'file',
	\ sources: [ #{ name: 'file' } ],
	\ })<CR>

lua<<EOF
---@param cmd string
---@param is_stopinsert? boolean
local execute = function(cmd, is_stopinsert)
	return function()
		if is_stopinsert then vim.cmd.stopinsert() end
		vim.schedule(function() vim.fn['ddu#ui#ff#execute'](cmd) end)
	end
end

---@param cmd string
---@param params? table
---@param is_stopinsert? boolean
local do_action = function(cmd, params, is_stopinsert)
	params = params or vim.empty_dict()
	return function()
		if is_stopinsert then vim.cmd.stopinsert() end
		vim.schedule(function() vim.fn['ddu#ui#do_action'](cmd, params) end)
	end
end

---@param name string
---@param params? table
---@param is_stopinsert? boolean
item_action = function(name, params, is_stopinsert)
	return do_action('itemAction', { name = name, params = params }, is_stopinsert)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = 'ddu-ff',
	callback = function()
		local opts = { silent = true, buffer = true }
		-- close ui
		vim.keymap.set('n', '<Esc>', do_action('quit'), opts)
		vim.keymap.set('n', 'q', do_action('quit'), opts)

		vim.keymap.set('n', '<CR>', item_action('default'), opts)
		vim.keymap.set('n', 'e', do_action("expandItem", { mode = "toggle" }), opts)
	end
})
EOF
