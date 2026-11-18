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

return T
