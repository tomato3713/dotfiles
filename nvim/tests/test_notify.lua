local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.o.columns = 100
			child.lua([[require('my.notify').setup({ timeout = 200 })]])
		end,
		post_once = child.stop,
	},
})

--- vim.schedule で後回しにした表示を child 側で走らせる
---@param ms? integer
local function wait(ms)
	child.lua('vim.wait(...)', { ms or 20 })
end

--- 表示中の通知ウィンドウを、上にあるものから順に返す
local function notifications()
	return child.lua([[
		local ret = {}
		for _, w in ipairs(vim.api.nvim_list_wins()) do
			local c = vim.api.nvim_win_get_config(w)
			if c.relative ~= '' then
				ret[#ret + 1] = {
					row = c.row,
					title = c.title[1][1],
					lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(w), 0, -1, false),
				}
			end
		end
		table.sort(ret, function(a, b) return a.row < b.row end)
		return ret
	]])
end

T['vim.notify の内容をレベル名のタイトル付きで右上に表示する'] = function()
	child.lua([[vim.notify('hello\nworld', vim.log.levels.WARN)]])
	wait()
	eq(notifications(), { { row = 0, title = ' WARN ', lines = { 'hello', 'world' } } })
end

T['title を渡すとレベル名の代わりにタイトルにする'] = function()
	child.lua([[vim.notify('x', vim.log.levels.INFO, { title = 'LSP' })]])
	wait()
	eq(notifications()[1].title, ' LSP ')
end

T['複数の通知は枠線の分を空けて下に積み重ねる'] = function()
	child.lua([[vim.notify('first\nsecond') vim.notify('third')]])
	wait()
	eq(vim.tbl_map(function(n) return n.row end, notifications()), { 0, 4 })
end

T['timeout が過ぎると閉じ、残りを上に詰める'] = function()
	child.lua([[
		vim.notify('short', nil, { timeout = 50 })
		vim.notify('long', nil, { timeout = 1000 })
	]])
	wait(150)
	eq(notifications(), { { row = 0, title = ' INFO ', lines = { 'long' } } })
end

T['文字列のレベルも受け付けて履歴に残す'] = function()
	child.lua([[vim.notify('boom', 'error')]])
	eq(child.lua_get([[require('my.notify').history[1].level]]), vim.log.levels.ERROR)
end

T['NotificationsClear は履歴と表示中の通知を消す'] = function()
	child.lua([[vim.notify('a')]])
	wait()
	child.cmd('NotificationsClear')
	eq({ #notifications(), child.lua_get([[#require('my.notify').history]]) }, { 0, 0 })
end

T['replace に表示中の通知を渡すと、新しく出さずに中身とタイトルを差し替え、履歴には両方残す'] = function()
	child.lua([[
		local n = require('my.notify')
		local first = n.notify('loading', vim.log.levels.INFO)
		n.notify('done\nok', vim.log.levels.WARN, { replace = first })
	]])
	wait()
	eq(notifications(), { { row = 0, title = ' WARN ', lines = { 'done', 'ok' } } })
	eq(child.lua_get([[vim.tbl_map(function(r) return r.msg end, require('my.notify').history)]]), { 'loading', 'done\nok' })
end

T['差し替えると timeout を数え直す'] = function()
	child.lua([[
		local n = require('my.notify')
		_G.first = n.notify('a', nil, { timeout = 100 })
	]])
	wait(60)
	child.lua([[require('my.notify').notify('b', nil, { timeout = 100, replace = _G.first })]])
	wait(60)
	eq(#notifications(), 1)
end

T['閉じた通知を replace に渡すと、新しい通知として出す'] = function()
	child.lua([[_G.first = require('my.notify').notify('old', nil, { timeout = 30 })]])
	wait(80)
	child.lua([[require('my.notify').notify('new', nil, { replace = _G.first })]])
	wait()
	eq(notifications(), { { row = 0, title = ' INFO ', lines = { 'new' } } })
end

T['中身がタイトルより短くても、タイトルが収まる幅にする'] = function()
	child.lua([[vim.notify('x', nil, { title = 'Messages' })]])
	wait()
	eq(child.lua_get([[vim.api.nvim_win_get_width(vim.iter(vim.api.nvim_list_wins()):find(function(w) return vim.api.nvim_win_get_config(w).relative ~= '' end))]]) >= #' Messages ', true)
end

return T
