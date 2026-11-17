local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			-- 実際の設定で使っている augends の組み合わせで検証する
			child.lua([[require('rc.dial')]])
		end,
		post_once = child.stop,
	},
})

--- 1 行だけのバッファを作り、col (0-based) にカーソルを置いて keys を打つ
---@return string line, integer col 操作後の行とカーソル列
local function dial(line, col, keys)
	child.api.nvim_buf_set_lines(0, 0, -1, false, { line })
	child.api.nvim_win_set_cursor(0, { 1, col })
	child.type_keys(keys)
	return child.api.nvim_get_current_line(), child.api.nvim_win_get_cursor(0)[2]
end

T['decimal'] = MiniTest.new_set()

T['decimal']['カーソル上の数を増やしてカーソルを末尾の桁に置く'] = function()
	eq({ dial('x = 9', 4, '<C-a>') }, { 'x = 10', 5 })
end

T['decimal']['カウントの分だけ減らし、負の数になれる'] = function()
	eq((dial('x = 2', 4, '5<C-x>')), 'x = -3')
end

T['decimal']['カーソルより後ろにある最初の数を対象にする'] = function()
	eq((dial('foo 1 2', 0, '<C-a>')), 'foo 2 2')
end

T['decimal']['単語の直後の - は引き算とみなして負の数として扱わない'] = function()
	eq((dial('a-1', 2, '<C-a>')), 'a-2')
	eq((dial('= -1', 2, '<C-a>')), '= 0')
end

T['decimal']['ゼロ埋めされた数は桁数を保つ'] = function()
	eq((dial('007', 0, '<C-a>')), '008')
end

T['date_slash'] = MiniTest.new_set()

T['date_slash']['カーソルが日にあれば日を増やし、月末を越えたら翌月に繰り上げる'] = function()
	eq({ dial('2026/01/31', 9, '<C-a>') }, { '2026/02/01', 9 })
end

T['date_slash']['カーソルが月にあれば月を増やし、日を月末に揃える'] = function()
	eq((dial('2026/01/31', 6, '<C-a>')), '2026/02/28')
end

T['date_slash']['月を減らして年をまたげる'] = function()
	eq((dial('2026/01/15', 5, '<C-x>')), '2025/12/15')
end

T['date_slash']['カーソルが日付より前にあれば日を増やす'] = function()
	eq((dial('due 2026/11/17', 0, '<C-a>')), 'due 2026/11/18')
end

T['constant'] = MiniTest.new_set()

T['constant']['true と false を切り替える'] = function()
	eq((dial('x = true', 4, '<C-a>')), 'x = false')
	eq((dial('x = false', 4, '<C-a>')), 'x = true')
end

T['constant']['曜日は末尾から先頭に回り込む'] = function()
	eq((dial('Sunday', 0, '<C-a>')), 'Monday')
	eq((dial('monday', 0, '<C-x>')), 'sunday')
end

T['constant']['word = true の語は単語の一部には一致しない'] = function()
	-- 曜日は単語単位でだけ一致させる設定なので、Mondays の中の Monday は対象外
	eq((dial('Mondays', 0, '<C-a>')), 'Mondays')
end

T['case'] = MiniTest.new_set()

T['case']['camelCase と snake_case を相互に切り替える'] = function()
	eq((dial('fooBarBaz', 0, '<C-a>')), 'foo_bar_baz')
	eq((dial('foo_bar_baz', 0, '<C-a>')), 'fooBarBaz')
end

T['優先順位'] = MiniTest.new_set()

T['優先順位']['カーソルを含む対象のうち開始位置が前のものを選ぶ'] = function()
	-- カーソルは日の "17" の上。数値 "17" より日付全体の方が前から始まるので、日付として扱う
	eq((dial('2026/11/30', 8, '<C-a>')), '2026/12/01')
end

T['優先順位']['開始位置が同じなら長い方を選ぶ'] = function()
	-- 年の上では数値と日付が同じ位置から始まる。日付として年を増やすので、うるう日は月末に揃う
	eq((dial('2024/02/29', 0, '<C-a>')), '2025/02/28')
end

T['優先順位']['filetype 固有の augends を共通のものより優先する'] = function()
	child.bo.filetype = 'typescript'
	eq((dial('let x = 1', 0, '<C-a>')), 'const x = 1')
	child.bo.filetype = 'lua'
	eq((dial('let x = 1', 0, '<C-a>')), 'let x = 2')
end

T['優先順位']['対象が無ければ何も変えない'] = function()
	eq({ dial('nothing here', 3, '<C-a>') }, { 'nothing here', 3 })
end

T['繰り返し'] = MiniTest.new_set()

T['繰り返し']['. で直前と同じ量だけ繰り返す'] = function()
	eq((dial('x = 1', 4, '3<C-a>.')), 'x = 7')
end

T['繰り返し']['1 回の操作は 1 回の undo で戻せる'] = function()
	eq((dial('x = 1', 4, '<C-a><C-a>u')), 'x = 2')
end

T['visual'] = MiniTest.new_set()

--- 複数行のバッファで visual mode の操作をする
local function dial_lines(lines, keys)
	child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	child.api.nvim_win_set_cursor(0, { 1, 0 })
	child.type_keys(keys)
	return child.api.nvim_buf_get_lines(0, 0, -1, false)
end

T['visual']['選択した各行の最初の対象を増やす'] = function()
	eq(dial_lines({ 'a 1', 'b true', 'c 3' }, 'Vj<C-a>'), { 'a 2', 'b false', 'c 3' })
	eq(child.fn.mode(), 'n')
end

T['visual']['g<C-a> は変更した行ごとに増やす量を 1 つずつ増やす'] = function()
	eq(dial_lines({ '0', 'none', '0', '0' }, 'VGg<C-a>'), { '1', 'none', '2', '3' })
end

T['visual']['文字単位の選択では選択範囲の中で始まる対象だけを選ぶ'] = function()
	-- "1" を飛ばして "2" から選択する
	eq(dial_lines({ '1 2' }, 'llv<C-a>'), { '1 3' })
end

return T
