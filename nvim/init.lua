local utils = require('my.utils')

utils.clear_vimrc_autocmd()

require('my.cmd').setup()

-- set keymap
require('my.keymap').global_mapping()
require('my.keymap').filetype_mapping()

vim.api.nvim_set_var('loaded_vimball', 1)
vim.api.nvim_set_var('loaded_vimballPlugin', 1)

-- encoding setting
vim.o.encoding = 'utf-8'                             -- バッファ内で扱う文字コード
vim.o.fileencoding = 'utf-8'                         -- 書き込み時UTF-8出力
vim.opt.fileencodings = { 'utf-8', 'cp932', 'sjis' } -- 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
vim.opt.fileformats = { 'unix', 'dos', 'mac' }

-- view
vim.opt.number = true
vim.o.pumblend = 10
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.laststatus = 3 -- v0.7.0 and later
vim.opt.cursorline = true
vim.o.list = true
vim.opt.listchars = {
	tab = '| ',
	trail = '·',
	eol = '↲',
	extends = '»',
	precedes = '←',
	nbsp = '␣',
}
vim.go.tabline = [[%!v:lua.require('my.tab').tabLineUpdate()]]
utils.nvim_create_autocmd({ 'ColorScheme' }, {
	callback = function()
		vim.api.nvim_set_hl(0, "my.utils", { fg = 'White', bg = 'Green' })
	end,
	desc = 'set selected tab highlight',
})
-- https://zenn.dev/kawarimidoll/articles/18ee967072def7
vim.treesitter.start = (function(wrapped)
	return function(bufnr, lang)
		lang = lang or vim.fn.getbufvar(bufnr or '', '&filetype')
		pcall(wrapped, bufnr, lang)
	end
end)(vim.treesitter.start)

-- editor setting
vim.o.smartindent = true -- スマートインデントを行う

vim.o.mousemoveevent = true

-- temporary file setting
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.opt.swapfile = false
vim.opt.backup = false

-- search
vim.o.ignorecase = true
vim.opt.wrapscan = false -- no loop when search word

-- set wildmenu wildmode=longest:full
vim.o.wildmenu = false
vim.opt.wildignore = {
	'*.o',
	'*.obj',
	'*.class',
	'*.exe',
	'*.jpg',
	'*.png',
	'*.jar',
	'*.apk',
	'*.pdf',
	'*.aux',
	'*.xlsx',
	'*.pptx',
	'*.docs',
}

-- terminal mode
local sysname = vim.loop.os_uname().sysname
if sysname == 'Windows_NT' then
	vim.o.shell = 'nyagos'
	vim.o.shcf = '-c'
elseif sysname == 'Darwin' then
	vim.o.shell = 'zsh'
end

utils.nvim_create_autocmd({ 'BufEnter' }, {
	callback = require('my.fn').none_ft_set_txt,
	desc = 'set default filetype as plain text',
})

require('rc.dein').init()

require('my.utils').try_catch( {
	try = function()
		vim.cmd('colorscheme monokai')
	end,
	catch = function(err)
		print('Error: ' .. err)
	end,
	})
