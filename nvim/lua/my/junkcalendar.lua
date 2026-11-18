-- JunkfileDiary の日記と月ごとの main.md をカレンダーで眺める
-- 日付の格子はファインダーの縦一列のリストに合わないため、専用のフロートとして作る

local junkfile = require('my.junkfile')
local finder = require('my.finder')

local M = {}

local ns = vim.api.nvim_create_namespace('my.junkcalendar')
vim.api.nvim_set_hl(0, 'JunkCalendarNote', { link = 'Title', default = true })
vim.api.nvim_set_hl(0, 'JunkCalendarEmpty', { link = 'Comment', default = true })
vim.api.nvim_set_hl(0, 'JunkCalendarToday', { link = 'Underlined', default = true })
vim.api.nvim_set_hl(0, 'JunkCalendarSelected', { link = 'Visual', default = true })

-- 1 日分のセルの幅。' 18 ' のように数字の左右に空白を置く
local CELL = 4
local WEEKDAYS = { 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa' }
-- 見出し 1 行 + 最大 6 週 + 区切り線 + main.md の行。月によって高さが変わらないよう固定する
local HEIGHT = 1 + 6 + 1 + 1

--- 正午にしておくと、夏時間の切り替わりがある地域でも日付がずれない
---@return integer
local function time_of(year, month, day)
	return os.time({ year = year, month = month, day = day, hour = 12 })
end

---@return integer
local function days_in_month(year, month)
	-- 翌月の 0 日は今月の末日になる
	return os.date('*t', time_of(year, month + 1, 0)).day
end

---@param time integer
---@return string
function M.diary_path(time)
	return junkfile.path(os.date('%Y-%m-%d.md', time), time)
end

---@param time integer
---@return string
function M.main_path(time)
	return junkfile.path('main.md', time)
end

---@class junkcalendar.Calendar
---@field year integer
---@field month integer
---@field day integer
---@field cells table<integer, { [1]: integer, [2]: integer }> 日 -> { 行 (0-based), 列 (0-based) }
---@field win integer
---@field buf integer
---@field preview_win? integer
---@field origin_win integer
---@field closed boolean
local Calendar = {}
Calendar.__index = Calendar

---@return integer
function Calendar:time()
	return time_of(self.year, self.month, self.day)
end

--- 選択中の日に表示・プレビューするメモ。日記が無ければその月の main.md、それも無ければ nil
---@return string?
function Calendar:note_path()
	for _, path in ipairs({ M.diary_path(self:time()), M.main_path(self:time()) }) do
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
	return nil
end

function Calendar:render()
	local first_wday = os.date('*t', time_of(self.year, self.month, 1)).wday - 1
	local ndays = days_in_month(self.year, self.month)
	local today = os.date('*t')

	local header = table.concat(vim.tbl_map(function(w) return ' ' .. w .. ' ' end, WEEKDAYS))
	local lines = { header }
	local marks = {}
	self.cells = {}
	local line = string.rep(' ', CELL * first_wday)
	for day = 1, ndays do
		local wday = (first_wday + day - 1) % 7
		local row, col = #lines, wday * CELL
		self.cells[day] = { row, col }
		line = line .. string.format(' %2d ', day)

		local exists = vim.fn.filereadable(M.diary_path(time_of(self.year, self.month, day))) == 1
		marks[#marks + 1] = { row, col + 1, col + 3, exists and 'JunkCalendarNote' or 'JunkCalendarEmpty', 10 }
		if self.year == today.year and self.month == today.month and day == today.day then
			marks[#marks + 1] = { row, col + 1, col + 3, 'JunkCalendarToday', 20 }
		end
		if day == self.day then
			marks[#marks + 1] = { row, col, col + CELL, 'JunkCalendarSelected', 30 }
		end
		if wday == 6 or day == ndays then
			lines[#lines + 1] = line
			line = ''
		end
	end
	while #lines < HEIGHT - 2 do
		lines[#lines + 1] = ''
	end
	lines[#lines + 1] = string.rep('─', CELL * #WEEKDAYS)
	lines[#lines + 1] = ' m: main.md'
	local main_exists = vim.fn.filereadable(M.main_path(self:time())) == 1
	marks[#marks + 1] = { #lines - 1, 4, #lines[#lines], main_exists and 'JunkCalendarNote' or 'JunkCalendarEmpty', 10 }

	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
	vim.bo[self.buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(self.buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4], priority = m[5] })
	end

	vim.api.nvim_win_set_config(self.win, { title = string.format(' Junkfile %04d/%02d ', self.year, self.month) })
	local cell = self.cells[self.day]
	vim.api.nvim_win_set_cursor(self.win, { cell[1] + 1, cell[2] + 1 })

	if self.preview_win then
		local path = self:note_path()
		finder.preview(self.preview_win, path and { text = path, file = path } or nil)
	end
end

--- 日単位で移動する。月をまたいでもよい
---@param delta integer
function Calendar:move_day(delta)
	local t = os.date('*t', time_of(self.year, self.month, self.day + delta))
	self.year, self.month, self.day = t.year, t.month, t.day
	self:render()
end

--- 月単位で移動する。移動先の月に同じ日が無ければ月末に揃える
---@param delta integer
function Calendar:move_month(delta)
	local months = self.year * 12 + (self.month - 1) + delta
	self.year, self.month = math.floor(months / 12), months % 12 + 1
	self.day = math.min(self.day, days_in_month(self.year, self.month))
	self:render()
end

function Calendar:goto_today()
	local t = os.date('*t')
	self.year, self.month, self.day = t.year, t.month, t.day
	self:render()
end

---@param on_done? fun() カレンダーを閉じて元のウィンドウに戻ってから呼ぶ
function Calendar:close(on_done)
	if self.closed then
		return
	end
	self.closed = true
	for _, win in ipairs({ self.win, self.preview_win }) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	if vim.api.nvim_win_is_valid(self.origin_win) then
		vim.api.nvim_set_current_win(self.origin_win)
	end
	if on_done then
		on_done()
	end
end

--- path が存在すれば開く。無ければ何もしない (誤って空のメモを作らないように)
---@param path string
function Calendar:open(path)
	if vim.fn.filereadable(path) == 0 then
		return
	end
	self:close(function()
		vim.cmd.edit(vim.fn.fnameescape(path))
	end)
end

function Calendar:set_keymaps()
	local function map(lhs, fn)
		vim.keymap.set('n', lhs, fn, { buffer = self.buf, nowait = true })
	end
	map('h', function() self:move_day(-1) end)
	map('l', function() self:move_day(1) end)
	map('k', function() self:move_day(-7) end)
	map('j', function() self:move_day(7) end)
	map('H', function() self:move_month(-1) end)
	map('L', function() self:move_month(1) end)
	map('t', function() self:goto_today() end)
	map('<CR>', function() self:open(M.diary_path(self:time())) end)
	map('m', function() self:open(M.main_path(self:time())) end)
	map('q', function() self:close() end)
	map('<Esc>', function() self:close() end)

	-- マウスなどで別ウィンドウへ移ったときにフロートが残らないようにする
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = self.buf,
		once = true,
		callback = function()
			vim.schedule(function() self:close() end)
		end,
	})
end

function Calendar:open_windows()
	local cal_width, cal_height = CELL * #WEEKDAYS + 2, HEIGHT + 2
	local with_preview = vim.o.columns >= cal_width + 40
	local preview_width = with_preview and math.min(80, vim.o.columns - cal_width - 4) or 0
	local preview_height = math.max(cal_height, math.floor(vim.o.lines * 0.6))
	local row = math.floor((vim.o.lines - preview_height) / 2)
	local col = math.floor((vim.o.columns - cal_width - preview_width) / 2)

	self.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[self.buf].bufhidden = 'wipe'
	-- filetype が空だと BufEnter で txt が設定されるなど、他の設定の対象になってしまうため明示する
	vim.bo[self.buf].filetype = 'junkcalendar'
	self.win = vim.api.nvim_open_win(self.buf, true, {
		relative = 'editor', style = 'minimal', border = 'single',
		row = row, col = col, width = cal_width - 2, height = cal_height - 2,
	})
	if with_preview then
		self.preview_win = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
			relative = 'editor', style = 'minimal', border = 'single',
			row = row, col = col + cal_width, width = preview_width - 2, height = preview_height - 2,
		})
		vim.wo[self.preview_win].number = true
	end
end

--- カレンダーを開く
---@param time? integer 最初に選択する日。省略時は今日
---@return junkcalendar.Calendar テストから状態を検査できるように返す
function M.open(time)
	local t = os.date('*t', time)
	local self = setmetatable({
		year = t.year,
		month = t.month,
		day = t.day,
		origin_win = vim.api.nvim_get_current_win(),
		closed = false,
	}, Calendar)
	self:open_windows()
	self:set_keymaps()
	self:render()
	return self
end

return M
