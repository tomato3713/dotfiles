local o = vim.o
local opt = vim.opt
local fn = vim.fn
local api = vim.api

-- encoding setting
o.encoding = 'utf-8'                 -- バッファ内で扱う文字コード
o.fileencoding = 'utf-8'             -- 書き込み時UTF-8出力
o.fileencodings = 'utf-8,cp932,sjis' -- 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
o.fileformats = 'unix,dos,mac'
o.completeslash = 'slash'

-- view
o.pumblend = 10
o.termguicolors = true
o.showmode = false
o.signcolumn = 'yes'
o.laststatus = 3 -- v0.7.0 and later

-- editor setting
o.imd = false        -- IM disable
o.sb = true          -- 水平分割時に下に表示
o.sr = false         -- 縦分割時を右に表示
o.smartindent = true -- スマートインデントを行う
o.list = true
opt.listchars = { tab = '>>', trail = '_', nbsp = '+' }

-- temporary file setting
opt.undofile = true
vim.opt.undodir = fn.stdpath("cache") .. "/undo"
opt.swapfile = false -- swapfileを作らない
opt.backup = false

opt.cursorline = true
opt.ruler = false

-- tab setting
o.ignorecase = true

-- set wildmenu wildmode=longest:full
o.wildmenu = false
opt.wildignore = { '*.o', '*.obj', '*.class', '*.exe', '*.jpg', '*.png', '*.jar', '*.apk', '*.pdf', '*.aux', '*.xlsx',
	'*.pptx', '*.docs' }
o.timeoutlen = 500

-- terminal mode
local sysname = vim.loop.os_uname().sysname
if sysname == 'win32' or sysname == 'win64' then
	o.shell = 'nyagos'
	o.shcf = '-c'
	fn.shellxquote('')
	fn.shellxescape('')
else
	o.shell = 'zsh'
end

--- close by 'q'
api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "help", "lspinfo", "qf" },
	callback = function()
		vim.keymap.set('n', 'q', '<Cmd>close<CR>')
	end,
})

-- set default filtype as plain text
function NoneFileTypeSetTxt()
	if string.len(o.filetype) == 0 then
		o.filetype = 'txt'
	end
end

api.nvim_create_autocmd({ "BufEnter" }, {
	callback = NoneFileTypeSetTxt,
})

-- toggle "，/．" and "、/。"
api.nvim_create_user_command(
	'CommaPeriod', function(opts)
		local cursor = fn.getcurpos()
		vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/、/，/ge')
		vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/。/．/ge')
		fn.setpos('.', cursor)
	end, { range = true })

api.nvim_create_user_command(
	'Kutoten', function(opts)
		local cursor = fn.getcurpos()
		vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/，/、/ge')
		vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/．/。/ge')
		fn.setpos('.', cursor)
	end, { range = true })

api.nvim_create_user_command(
	'CountChars', function(opts)
		local cursor = fn.getcurpos()
		vim.api.nvim_command('keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/./&/gn')
		fn.setpos('.', cursor)
	end, { range = true })

-- buffer and tab
for k, v in pairs({
	['<C-n>'] = '<Cmd>bnext<CR>',
	['<C-p>'] = '<Cmd>bprevious<CR>',
	['<M-n>'] = '<Cmd>tabnext<CR>',
	['<M-p>'] = '<Cmd>tabprevious<CR>',
}) do
	vim.keymap.set('', k, v)
end

-- dein Scripts
local dein_dir = fn.expand('~/.cache/dein')
local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

-- https://github.com/settings/tokens
api.nvim_set_var('dein#install_github_api_token', os.getenv('DEIN_GITHUB_TOKEN'))

if not string.find(api.nvim_get_option('runtimepath'), '/dein.vim') then
	if not (fn.isdirectory(dein_repo_dir) == 1) then
		os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
	end
	api.nvim_set_option('runtimepath', dein_repo_dir .. ',' .. api.nvim_get_option('runtimepath'))
end

local dein = require('dein')

dein.setup {
	auto_remote_plugins = false,
	enable_notification = true,
}

dein.begin(dein_dir)
dein.load_toml(fn.expand('~/.config/nvim/dein.toml'), { lazy = 0 })
dein.end_()
dein.save_state()

if (dein.check_install()) then
	dein.install()
end

local removed_plugins = dein.check_clean()
if vim.fn.len(removed_plugins) > 0 then
	vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
	dein.recache_runtimepath()
end

api.nvim_create_user_command('DeinClearCache', function() dein.recache_runtimepath() end, {})
