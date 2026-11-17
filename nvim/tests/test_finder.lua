local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			-- プレビューは幅 100 列以上でのみ表示するため、どのテストでも表示される大きさにしておく
			child.o.columns = 200
			child.o.lines = 50
			child.lua([[_G.finder = require('my.finder')]])
		end,
		post_once = child.stop,
	},
})

--- 子プロセスでファインダーを開き、_G.f に保持する
---@param opts_src string finder.start() に渡す Lua 式
local function start(opts_src)
	child.lua('_G.f = finder.start(' .. opts_src .. ')')
end

local function list_lines()
	return child.lua_get([[vim.api.nvim_buf_get_lines(_G.f.list_buf, 0, -1, false)]])
end

local function selected_text()
	return child.lua_get([[(_G.f:selected() or {}).text]])
end

local function float_count()
	return child.lua_get([[#vim.tbl_filter(function(w)
		return vim.api.nvim_win_get_config(w).relative ~= ''
	end, vim.api.nvim_list_wins())]])
end

local function type_query(keys)
	child.type_keys(keys)
	-- TextChangedI は入力が落ち着いてから発火するため、反映を待つ
	child.lua([[vim.wait(50)]])
end

T['絞り込み'] = MiniTest.new_set()

T['絞り込み']['クエリが空のときは items を元の順序のまま表示する'] = function()
	start([[{ title = 't', items = { { text = 'banana' }, { text = 'apple' }, { text = 'cherry' } } }]])
	eq(list_lines(), { 'banana', 'apple', 'cherry' })
	eq(selected_text(), 'banana')
end

T['絞り込み']['クエリにあいまい一致する候補だけを表示する'] = function()
	start([[{ title = 't', items = { { text = 'lua/my/finder.lua' }, { text = 'README.md' }, { text = 'lua/rc/mr.lua' } } }]])
	type_query('mfi')
	eq(list_lines(), { 'lua/my/finder.lua' })
end

T['絞り込み']['同じ text の候補が複数あってもそれぞれ別の item として残る'] = function()
	start([[{ title = 't', items = { { text = 'dup', data = 1 }, { text = 'dup', data = 2 }, { text = 'other' } } }]])
	type_query('dup')
	eq(child.lua_get([[vim.tbl_map(function(r) return r.item.data end, _G.f.results)]]), { 1, 2 })
end

T['絞り込み']['一致した文字をマルチバイト文字の後ろでもバイト位置でハイライトする'] = function()
	start([[{ title = 't', items = { { text = 'あいう abc' } } }]])
	type_query('b')
	local marks = child.lua_get([[vim.tbl_map(function(m)
		return { m[3], m[4].end_col, m[4].hl_group }
	end, vim.api.nvim_buf_get_extmarks(_G.f.list_buf, -1, 0, -1, { details = true }))]])
	-- 'あいう ' は 3 バイト x 3 + 空白 1 = 10 バイト、'a' の次が 'b'
	eq(marks, { { 11, 12, 'FinderMatch' } })
end

T['絞り込み']['groups を指定するとグループ順に見出しを付けて並べる'] = function()
	start([[{
		title = 't',
		groups = { { title = 'Def' }, { title = 'Ref' } },
		items = { { text = 'ref1', group = 2 }, { text = 'def1', group = 1 }, { text = 'ref2', group = 2 } },
	}]])
	eq(list_lines(), { '── Def ──', 'def1', '── Ref ──', 'ref1', 'ref2' })
	-- 見出し行は選択対象にしない
	eq(selected_text(), 'def1')
end

T['絞り込み']['filter_text を指定するとその文字列だけを絞り込みの対象にする'] = function()
	start([[{ title = 't', items = {
		{ text = 'a.lua: xyz', filter_text = 'a.lua' },
		{ text = 'xyz.lua: abc', filter_text = 'xyz.lua' },
	} }]])
	type_query('xyz')
	eq(list_lines(), { 'xyz.lua: abc' })
end

T['入力欄'] = MiniTest.new_set()

--- 入力欄の値をそのまま 1 件の候補にする input を持つファインダーを開く
local function start_with_input(extra)
	start([[vim.tbl_extend('force', {
		title = 't',
		inputs = { {
			title = 'Source',
			default = 'init',
			on_change = function(value, f)
				_G.changes = (_G.changes or 0) + 1
				f:set_producer(function(push, done)
					push({ { text = 'from:' .. value } })
					done()
				end)
			end,
		} },
	}, ]] .. (extra or '{}') .. ')')
	child.lua([[vim.wait(200, function() return #_G.f.results > 0 end)]])
end

T['入力欄']['起動時に既定値で on_change を呼んで候補を作る'] = function()
	start_with_input()
	eq(list_lines(), { 'from:init' })
	-- 追加の入力欄があるときは、下の入力欄が絞り込み欄であることをタイトルで示す
	eq(child.lua_get([[vim.api.nvim_win_get_config(_G.f.prompt_win).title[1][1] ]]), ' Filter ')
end

T['入力欄']['入力が止まってから on_change を 1 回だけ呼んで候補を作り直す'] = function()
	start_with_input('{ focus = 1 }')
	child.type_keys('a', 'b', 'c')
	child.lua([[vim.wait(1000, function() return _G.f.items[1].text == 'from:initabc' end)]])
	eq(list_lines(), { 'from:initabc' })
	-- 起動時の 1 回と、打鍵をまとめた 1 回
	eq(child.lua_get('_G.changes'), 2)
end

T['入力欄']['<C-g> で入力欄を上から順に巡回し、移動してもファインダーを閉じない'] = function()
	start_with_input()
	local input_win = child.lua_get([[_G.f.input_wins[1] ]])
	local prompt_win = child.lua_get([[_G.f.prompt_win]])
	eq(child.api.nvim_get_current_win(), prompt_win)
	child.type_keys('<C-g>')
	eq(child.api.nvim_get_current_win(), input_win)
	child.type_keys('<C-g>')
	eq(child.api.nvim_get_current_win(), prompt_win)
	child.lua([[vim.wait(50)]])
	eq(child.lua_get([[_G.f.closed]]), false)
end

T['入力欄']['既定値の入った入力欄では行末から続きを入力できる'] = function()
	start_with_input('{ focus = 1 }')
	child.type_keys('X')
	eq(child.api.nvim_get_current_line(), 'initX')
end

T['入力欄']['別の入力欄に移って入力しても、待機中の on_change は取り消されない'] = function()
	start([[{
		title = 't',
		focus = 1,
		inputs = {
			{ title = 'A', on_change = function(v) _G.a = v end },
			{ title = 'B', on_change = function(v) _G.b = v end },
		},
	}]])
	-- 待ち時間 (200ms) が過ぎる前に次の入力欄へ移って入力する
	child.type_keys('x', '<C-g>', 'y')
	child.lua([[vim.wait(1000, function() return _G.a == 'x' and _G.b == 'y' end)]])
	eq(child.lua_get('{ _G.a, _G.b }'), { 'x', 'y' })
end

T['入力欄']['作り直す前の producer から遅れて届いた候補は捨てる'] = function()
	start([[{ title = 't' }]])
	child.lua([[
		_G.f:set_producer(function(push) _G.stale_push = push end)
		_G.f:set_producer(function(push, done) push({ { text = 'new' } }) done() end)
		_G.stale_push({ { text = 'stale' } })
	]])
	child.lua([[vim.wait(200)]])
	eq(list_lines(), { 'new' })
end

T['カーソル移動'] = MiniTest.new_set()

T['カーソル移動']['見出し行を飛ばして次の候補へ移る'] = function()
	start([[{
		title = 't',
		groups = { { title = 'A' }, { title = 'B' } },
		items = { { text = 'a1', group = 1 }, { text = 'b1', group = 2 } },
	}]])
	child.type_keys('<C-n>')
	eq(selected_text(), 'b1')
end

T['カーソル移動']['末尾から次へ進むと先頭に回り込む'] = function()
	start([[{ title = 't', items = { { text = 'a' }, { text = 'b' } } }]])
	child.type_keys('<C-n>', '<C-n>')
	eq(selected_text(), 'a')
	child.type_keys('<C-p>')
	eq(selected_text(), 'b')
end

T['カーソル移動']['クエリを変えると選択が先頭の候補に戻る'] = function()
	start([[{ title = 't', items = { { text = 'abc' }, { text = 'abd' }, { text = 'xyz' } } }]])
	child.type_keys('<C-n>')
	eq(selected_text(), 'abd')
	type_query('ab')
	eq(selected_text(), 'abc')
end

T['カーソル移動']['非同期に候補が追加されても選択中の item を保つ'] = function()
	start([[{ title = 't', items = { { text = 'a' }, { text = 'b' } } }]])
	child.type_keys('<C-n>')
	child.lua([[_G.f:push({ { text = 'c' } })]])
	child.lua([[vim.wait(200, function() return #_G.f.results == 3 end)]])
	eq(selected_text(), 'b')
end

T['決定と中断'] = MiniTest.new_set()

T['決定と中断']['<CR> で選択中の item と開き方 edit を on_select に渡す'] = function()
	start([[{
		title = 't',
		items = { { text = 'a' }, { text = 'b' } },
		on_select = function(item, cmd) _G.got = { item.text, cmd } end,
	}]])
	child.type_keys('<C-n>', '<CR>')
	child.lua([[vim.wait(200, function() return _G.got ~= nil end)]])
	eq(child.lua_get('_G.got'), { 'b', 'edit' })
	eq(float_count(), 0)
end

T['決定と中断']['<C-v> では開き方 vsplit を on_select に渡す'] = function()
	start([[{
		title = 't',
		items = { { text = 'a' } },
		on_select = function(item, cmd) _G.got = cmd end,
	}]])
	child.type_keys('<C-v>')
	child.lua([[vim.wait(200, function() return _G.got ~= nil end)]])
	eq(child.lua_get('_G.got'), 'vsplit')
end

T['決定と中断']['<Esc> で閉じると on_cancel を呼びフロートを残さない'] = function()
	start([[{ title = 't', items = { { text = 'a' } }, on_cancel = function() _G.cancelled = true end }]])
	child.type_keys('<Esc>')
	child.lua([[vim.wait(200, function() return _G.cancelled end)]])
	eq(child.lua_get('_G.cancelled'), true)
	eq(float_count(), 0)
	eq(child.fn.mode(), 'n')
end

T['決定と中断']['<C-q> で絞り込んだ候補だけを quickfix に送る'] = function()
	start([[{ title = 'qf', items = {
		{ text = 'x.lua:1', file = 'x.lua', lnum = 1 },
		{ text = 'y.lua:2', file = 'y.lua', lnum = 2 },
	} }]])
	type_query('y')
	child.type_keys('<C-q>')
	child.lua([[vim.wait(200, function() return vim.fn.getqflist({ size = 1 }).size > 0 end)]])
	eq(child.lua_get([[vim.tbl_map(function(e) return e.lnum end, vim.fn.getqflist())]]), { 2 })
	eq(child.lua_get([[vim.fn.getqflist({ title = 1 }).title]]), 'qf')
end

T['open'] = MiniTest.new_set()

T['open']['ファイルを開いて指定した行と列にカーソルを置く'] = function()
	local path = child.lua_get([[(function()
		local p = vim.fn.tempname()
		vim.fn.writefile({ 'one', 'two', 'three' }, p)
		return p
	end)()]])
	child.lua('finder.open({ text = "", file = ..., lnum = 3, col = 2 })', { path })
	-- macOS では一時ディレクトリが /private 配下へのシンボリックリンクなので実体で比べる
	eq(child.fn.resolve(child.api.nvim_buf_get_name(0)), child.fn.resolve(path))
	eq(child.api.nvim_win_get_cursor(0), { 3, 1 })
end

T['open']['split 指定では新しいウィンドウで開く'] = function()
	child.lua([[finder.open({ text = '', bufnr = vim.api.nvim_create_buf(true, false) }, 'split')]])
	eq(#child.api.nvim_list_wins(), 2)
end

T['プレビュー'] = MiniTest.new_set()

T['プレビュー']['位置を持つ item ではファイルの該当行にカーソルを合わせて表示する'] = function()
	local path = child.lua_get([[(function()
		local p = vim.fn.tempname() .. '.lua'
		vim.fn.writefile({ 'local a = 1', 'local b = 2', 'local c = 3' }, p)
		return p
	end)()]])
	start(string.format([[{ title = 't', items = { { text = 'c', file = %q, lnum = 3 } } }]], path))
	eq(child.lua_get([[vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(_G.f.preview_win), 0, -1, false)]]),
		{ 'local a = 1', 'local b = 2', 'local c = 3' })
	eq(child.lua_get([[vim.api.nvim_win_get_cursor(_G.f.preview_win)[1] ]]), 3)
end

T['プレビュー']['preview = false ではプレビューウィンドウを作らない'] = function()
	start([[{ title = 't', items = { { text = 'a' } }, preview = false }]])
	eq(child.lua_get([[_G.f.preview_win]]), vim.NIL)
	eq(float_count(), 2)
end

T['command'] = MiniTest.new_set()

T['command']['複数回に分かれて届く出力も 1 行ずつ item にする'] = function()
	-- 出力が大きいとパイプの都合で行の途中で分割されて届く
	start([[{ title = 't', producer = finder.command({ 'seq', '1', '20000' }, function(line)
		return line ~= '' and { text = line } or nil
	end) }]])
	child.lua([[vim.wait(3000, function() return not _G.f.loading end)]])
	eq(child.lua_get([[#_G.f.items]]), 20000)
	eq(child.lua_get([[_G.f.items[20000].text]]), '20000')
end

T['command']['閉じると外部コマンドを止める'] = function()
	start([[{ title = 't', producer = finder.command({ 'sleep', '10' }, function() end) }]])
	child.type_keys('<Esc>')
	child.lua([[vim.wait(1000, function() return not _G.f.loading end)]])
	eq(child.lua_get([[_G.f.loading]]), false)
end

T['ui_select'] = MiniTest.new_set()

T['ui_select']['選んだ要素と添字を on_choice に渡す'] = function()
	child.lua([[finder.ui_select({ { name = 'x' }, { name = 'y' } }, {
		format_item = function(it) return it.name end,
	}, function(item, idx) _G.got = { item and item.name, idx } end)]])
	child.type_keys('<C-n>', '<CR>')
	child.lua([[vim.wait(200, function() return _G.got ~= nil end)]])
	eq(child.lua_get('_G.got'), { 'y', 2 })
end

T['ui_select']['中断すると on_choice に nil を渡す'] = function()
	child.lua([[finder.ui_select({ 'a' }, {}, function(item, idx) _G.got = { item == nil, idx == nil } end)]])
	child.type_keys('<Esc>')
	child.lua([[vim.wait(200, function() return _G.got ~= nil end)]])
	eq(child.lua_get('_G.got'), { true, true })
end

return T
