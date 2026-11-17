local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			-- 実際のメモ置き場を汚さないよう、一時ディレクトリをキャッシュディレクトリにする。
			-- macOS の一時ディレクトリは /private 配下へのシンボリックリンクなので、開いたバッファ名と揃うよう実体にしておく
			child.lua([[
				local tmp = vim.fn.tempname()
				vim.fn.mkdir(tmp, 'p')
				vim.env.XDG_CACHE_HOME = vim.fn.resolve(tmp)
				_G.junkfile = require('my.junkfile')
				require('my.cmd').setup()
			]])
		end,
		post_once = child.stop,
	},
})

T['path'] = MiniTest.new_set()

T['path']['キャッシュディレクトリ配下の年月ディレクトリに置く'] = function()
	-- 2026-11-17 12:00:00 (ローカル時刻)
	local time = os.time({ year = 2026, month = 11, day = 17, hour = 12 })
	eq(child.lua_get([[junkfile.path('memo.md', ...)]], { time }),
		child.lua_get([[vim.env.XDG_CACHE_HOME]]) .. '/junkfile/2026/11/memo.md')
end

T['path']['XDG_CACHE_HOME が無ければ ~/.cache を使う'] = function()
	child.lua([[vim.env.XDG_CACHE_HOME = nil]])
	eq(child.lua_get([[junkfile.dir()]]), vim.fn.expand('~/.cache') .. '/junkfile')
end

T['open'] = MiniTest.new_set()

T['open']['年月ディレクトリが無くても作ってファイルを開く'] = function()
	child.lua([[junkfile.open('note.md')]])
	local expected = child.lua_get([[junkfile.path('note.md')]])
	eq(child.api.nvim_buf_get_name(0), expected)
	eq(child.fn.isdirectory(vim.fs.dirname(expected)), 1)
end

T['commands'] = MiniTest.new_set()

T['commands'][':JunkfileDiary は今日の日付のファイルを開く'] = function()
	child.cmd('JunkfileDiary')
	eq(vim.fs.basename(child.api.nvim_buf_get_name(0)), os.date('%Y-%m-%d.md'))
end

T['commands'][':JunkNote は今月の main.md を開く'] = function()
	child.cmd('JunkNote')
	eq(child.api.nvim_buf_get_name(0), child.lua_get([[junkfile.path('main.md')]]))
end

return T
