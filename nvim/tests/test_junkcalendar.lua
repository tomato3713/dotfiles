local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.o.columns = 200
			child.o.lines = 50
			-- 実際のメモ置き場を汚さないよう、一時ディレクトリをキャッシュディレクトリにする
			child.lua([[
				local tmp = vim.fn.tempname()
				vim.fn.mkdir(tmp, 'p')
				vim.env.XDG_CACHE_HOME = vim.fn.resolve(tmp)
				_G.cal = require('my.junkcalendar')
				_G.junkfile = require('my.junkfile')
				require('my.cmd').setup()
				_G.time_of = function(y, m, d) return os.time({ year = y, month = m, day = d, hour = 12 }) end
				--- 日記を作る
				_G.diary = function(y, m, d, lines)
					local path = cal.diary_path(time_of(y, m, d))
					vim.fn.mkdir(vim.fs.dirname(path), 'p')
					vim.fn.writefile(lines or { 'diary' }, path)
				end
			]])
		end,
		post_once = child.stop,
	},
})

---@param y integer
---@param m integer
---@param d integer
local function open_at(y, m, d)
	child.lua(string.format([[_G.c = cal.open(time_of(%d, %d, %d))]], y, m, d))
end

local function title()
	return child.lua_get([[vim.api.nvim_win_get_config(_G.c.win).title[1][1] ]])
end

local function selected()
	return child.lua_get([[{ _G.c.year, _G.c.month, _G.c.day }]])
end

local function cal_lines()
	return child.lua_get([[vim.api.nvim_buf_get_lines(_G.c.buf, 0, -1, false)]])
end

--- day の数字に付いているハイライトの一覧
local function day_highlights(day)
	return child.lua_get([[(function(day)
		local cell = _G.c.cells[day]
		local groups = {}
		for _, m in ipairs(vim.api.nvim_buf_get_extmarks(_G.c.buf, -1, { cell[1], cell[2] + 1 }, { cell[1], cell[2] + 1 }, { details = true, overlap = true })) do
			groups[#groups + 1] = m[4].hl_group
		end
		table.sort(groups)
		return groups
	end)(...)]], { day })
end

T['表示'] = MiniTest.new_set()

T['表示']['日曜始まりで、1 日を曜日の列に合わせて並べる'] = function()
	-- 2026/12/01 は火曜日
	open_at(2026, 12, 1)
	local lines = cal_lines()
	eq(lines[1], ' Su  Mo  Tu  We  Th  Fr  Sa ')
	eq(lines[2], '          1   2   3   4   5 ')
	eq(lines[6], ' 27  28  29  30  31 ')
	eq(title(), ' Junkfile 2026/12 ')
end

T['表示']['日記がある日と無い日を別の色で示す'] = function()
	child.lua([[diary(2026, 11, 3)]])
	open_at(2026, 11, 18)
	eq(day_highlights(3), { 'JunkCalendarNote' })
	eq(day_highlights(4), { 'JunkCalendarEmpty' })
end

T['表示']['選択中の日を強調する'] = function()
	open_at(2026, 11, 18)
	eq(vim.tbl_contains(day_highlights(18), 'JunkCalendarSelected'), true)
	eq(vim.tbl_contains(day_highlights(17), 'JunkCalendarSelected'), false)
end

T['表示']['選択中の日の日記をプレビューし、無ければその月の main.md をプレビューする'] = function()
	child.lua([[
		diary(2026, 11, 3, { 'day three' })
		local main = cal.main_path(time_of(2026, 11, 1))
		vim.fn.writefile({ 'monthly' }, main)
	]])
	open_at(2026, 11, 3)
	local preview = [[vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(_G.c.preview_win), 0, -1, false)]]
	eq(child.lua_get(preview), { 'day three' })
	child.type_keys('l')
	eq(child.lua_get(preview), { 'monthly' })
end

T['移動'] = MiniTest.new_set()

T['移動']['l と h で 1 日ずつ動き、月をまたぐと表示する月も変わる'] = function()
	open_at(2026, 11, 30)
	child.type_keys('l')
	eq(selected(), { 2026, 12, 1 })
	eq(title(), ' Junkfile 2026/12 ')
	child.type_keys('h')
	eq(selected(), { 2026, 11, 30 })
end

T['移動']['j と k で 1 週間ずつ動く'] = function()
	open_at(2026, 11, 18)
	child.type_keys('j')
	eq(selected(), { 2026, 11, 25 })
	child.type_keys('k', 'k')
	eq(selected(), { 2026, 11, 11 })
end

T['移動']['L と H で月を移り、移動先に同じ日が無ければ月末に揃える'] = function()
	open_at(2026, 1, 31)
	child.type_keys('L')
	eq(selected(), { 2026, 2, 28 })
	child.type_keys('H', 'H')
	eq(selected(), { 2025, 12, 28 })
end

T['移動']['t で今日に戻る'] = function()
	open_at(2020, 1, 1)
	child.type_keys('t')
	local today = os.date('*t')
	eq(selected(), { today.year, today.month, today.day })
end

T['移動']['カーソルを選択中の日の上に置く'] = function()
	open_at(2026, 11, 18)
	local cell = child.lua_get([[_G.c.cells[18] ]])
	eq(child.api.nvim_win_get_cursor(0), { cell[1] + 1, cell[2] + 1 })
end

T['開く'] = MiniTest.new_set()

T['開く']['<CR> で日記がある日はその日記を開いてカレンダーを閉じる'] = function()
	child.lua([[diary(2026, 11, 18)]])
	open_at(2026, 11, 18)
	child.type_keys('<CR>')
	eq(child.api.nvim_buf_get_name(0), child.lua_get([[cal.diary_path(time_of(2026, 11, 18))]]))
	eq(child.lua_get([[_G.c.closed]]), true)
end

T['開く']['<CR> で日記が無い日は何もせず、日記も作らない'] = function()
	open_at(2026, 11, 18)
	child.type_keys('<CR>')
	eq(child.lua_get([[_G.c.closed]]), false)
	eq(child.fn.filereadable(child.lua_get([[cal.diary_path(time_of(2026, 11, 18))]])), 0)
end

T['開く']['m でその月の main.md を開く'] = function()
	child.lua([[
		local main = cal.main_path(time_of(2026, 11, 1))
		vim.fn.mkdir(vim.fs.dirname(main), 'p')
		vim.fn.writefile({ 'monthly' }, main)
	]])
	open_at(2026, 11, 18)
	child.type_keys('m')
	eq(child.api.nvim_buf_get_name(0), child.lua_get([[cal.main_path(time_of(2026, 11, 1))]]))
end

T['開く']['q で閉じて元のウィンドウに戻る'] = function()
	local origin = child.api.nvim_get_current_win()
	open_at(2026, 11, 18)
	child.type_keys('q')
	eq(child.api.nvim_get_current_win(), origin)
	eq(#child.api.nvim_list_wins(), 1)
end

T['コマンド'] = MiniTest.new_set()

T['コマンド'][':JunkCalendar で今日を選択した状態で開く'] = function()
	child.cmd('JunkCalendar')
	local today = os.date('*t')
	eq(child.bo.filetype, 'junkcalendar')
	eq(child.lua_get([[vim.api.nvim_win_get_config(0).title[1][1] ]]),
		string.format(' Junkfile %04d/%02d ', today.year, today.month))
end

return T
