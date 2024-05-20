local utils = require('rc.utils')

utils.clear_vimrc_autocmd()

-- encoding setting
vim.o.encoding = 'utf-8'                             -- バッファ内で扱う文字コード
vim.o.fileencoding = 'utf-8'                         -- 書き込み時UTF-8出力
vim.opt.fileencodings = { 'utf-8', 'cp932', 'sjis' } -- 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
vim.opt.fileformats = { 'unix', 'dos', 'mac' }

-- view
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

-- editor setting
vim.o.smartindent = true -- スマートインデントを行う

vim.opt.mousemoveevent = true

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

vim.api.nvim_set_var('loaded_vimball', 1)
vim.api.nvim_set_var('loaded_vimballPlugin', 1)

-- terminal mode
local sysname = vim.loop.os_uname().sysname
if sysname == 'Windows_NT' then
	vim.o.shell = 'nyagos'
	vim.o.shcf = '-c'
elseif sysname == 'Darwin' then
	vim.o.shell = 'zsh'
end

-- vim.keymap.set('n', '<C-n>', ':bnext<CR>')
-- vim.keymap.set('n', '<C-p>', ':bnext<CR>')

vim.keymap.set('n', '<C-w>t', ':split | terminal<CR>')

utils.nvim_create_autocmd({ 'ColorScheme' }, {
	callback = function()
		vim.api.nvim_set_hl(0, "TabLineSel", { fg = 'White', bg = 'Green' })
	end,
	desc = 'set selected tab highlight',
})

function TabLineUpdate()
	local tabline = ""
	for index = 1, vim.fn.tabpagenr('$') do
		-- select the highlighting
		if index == vim.fn.tabpagenr() then
			tabline = tabline .. '%#TabLineSel#'
		else
			tabline = tabline .. '%#TabLine#'
		end

		-- set the tab page number (for mouse clicks)
		tabline = tabline .. '%' .. index .. 'T'

		tabline = tabline .. " # " .. index .. ' #' .. " |"
	end

	-- after the last tab fill with TabLineFill and reset tab page nr
	tabline = tabline .. '%#TabLineFill#%T'

	-- right-align the label to close the current tab page
	if vim.fn.tabpagenr('$') > 1 then
		tabline = tabline .. '%=%#TabLine#%999Xclose'
	end

	return tabline
end

vim.go.tabline = "%!v:lua.TabLineUpdate()"

--- close by 'q'
utils.nvim_create_autocmd({ 'FileType' }, {
	pattern = { 'help', 'lspinfo', 'qf' },
	callback = function()
		vim.keymap.set('n', 'q', function()
			vim.api.nvim_win_close(0, true)
		end, { buffer = true, noremap = true })
	end,
	desc = 'close window with "q"',
})

-- set default filtype as plain text
function NoneFileTypeSetTxt()
	if string.len(vim.o.filetype) == 0 then
		vim.o.filetype = 'txt'
	end
end

utils.nvim_create_autocmd({ 'BufEnter' }, {
	callback = NoneFileTypeSetTxt,
	desc = 'set default filetype as plain text',
})

-- toggle "，/．" and "、/。"
vim.api.nvim_create_user_command('CommaPeriod', function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/、/，/ge')
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/。/．/ge')
	vim.fn.setpos('.', cursor)
end, { range = true })

vim.api.nvim_create_user_command('Kutoten', function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/，/、/ge')
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/．/。/ge')
	vim.fn.setpos('.', cursor)
end, { range = true })

vim.api.nvim_create_user_command('CountChars', function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/./&/gn')
	vim.fn.setpos('.', cursor)
end, { range = true })

-- http://advweb.seesaa.net/article/13443981.html
-- jump to the last line the cursor was on.
-- utils.nvim_create_autocmd({ 'BufRead' }, {
-- 	callback = function()
-- 		if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line('$') then
-- 			vim.cmd.stopinsert()
-- 			vim.api.nvim_feedkeys('g`"', 'n', false)
-- 		end
-- 	end,
-- 	desc = 'jump to the last line the cursor was on',
-- })

-- dein Scripts
local dein_dir = vim.fn.expand('~/.cache/dein')
local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

-- https://github.com/settings/tokens
vim.api.nvim_set_var('dein#install_github_api_token', os.getenv('DEIN_GITHUB_TOKEN'))
vim.api.nvim_set_option('runtimepath', dein_repo_dir .. ',' .. vim.api.nvim_get_option('runtimepath'))

-- if not installed dein.vim, install.
if not (vim.fn.isdirectory(dein_repo_dir) == 1) then
	os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
	return
end

local dein = require('dein')

dein.setup({
	auto_remote_plugins = false,
	enable_notification = true,
})

dein.begin(dein_dir)
dein.load_toml(vim.fn.expand('~/.config/nvim/dein.toml'), { lazy = 0 })
dein.end_()
dein.save_state()

if dein.check_install() then
	dein.install()
end

local removed_plugins = dein.check_clean()
if vim.fn.len(removed_plugins) > 0 then
	vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
	dein.recache_runtimepath()
end

vim.api.nvim_create_user_command('DeinClearCache', function()
	dein.recache_runtimepath()
end, {})
