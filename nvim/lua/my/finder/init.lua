-- 自作ファジーファインダー
-- 入力欄・候補リスト・プレビューの 3 つのフローティングウィンドウで構成する。
-- 絞り込みは組み込みの matchfuzzypos() に任せる。Lua で自前実装するより C 実装の方が速く、
-- 日本語などマルチバイト文字も扱えるため。

---@class finder.Item
---@field text string 表示する文字列。filter_text が無ければ絞り込みの対象にもなる
---@field filter_text? string 絞り込みの対象を text の一部に限るときに指定する。ハイライト位置を合わせるため text の先頭部分であること
---@field icon? string text の前に表示する。絞り込みの対象外
---@field icon_hl? string
---@field group? integer opts.groups の添字。グループ見出しを表示するときに使う
---@field file? string
---@field bufnr? integer
---@field lnum? integer 1-based
---@field col? integer 1-based (byte)
---@field data? any source が自由に使う値

---@class finder.Opts
---@field title string
---@field items? finder.Item[]
---@field producer? fun(push: fun(items: finder.Item[]), done: fun()): fun()? 非同期に候補を追加する。中断用の関数を返す
---@field groups? { title: string, hl?: string }[] 指定すると結果をグループ順に並べて見出しを付ける
---@field on_select? fun(item: finder.Item, cmd: finder.OpenCmd) 省略時は item の位置を開く
---@field on_cancel? fun()
---@field preview? boolean 省略時 true
---@field inputs? finder.Input[] 絞り込み欄の上に並べる追加の入力欄。候補そのものを入力で作り直したいときに使う
---@field focus? integer 起動時にカーソルを置く inputs の添字。省略時は絞り込み欄

---@class finder.Input
---@field title string
---@field default? string
---@field on_change fun(value: string, finder: finder.Finder) 起動時と、入力が止まってから呼ばれる

---@alias finder.OpenCmd 'edit'|'split'|'vsplit'|'tab'

local M = {}

-- 表示件数の上限。これ以上は絞り込まないと見えないが、描画コストを一定に抑えられる
local LIMIT = 500
local ns = vim.api.nvim_create_namespace('my.finder')

vim.api.nvim_set_hl(0, 'FinderMatch', { link = 'Search', default = true })
vim.api.nvim_set_hl(0, 'FinderGroup', { link = 'Title', default = true })

---@param path string
---@return string
local function relpath(path)
	-- fnamemodify('', ':~:.') はカレントディレクトリを返してしまうため、名前のないバッファは別扱いにする
	if path == '' then
		return '[No Name]'
	end
	return vim.fn.fnamemodify(path, ':~:.')
end
M.relpath = relpath

local buffer_cmd = {
	edit = 'buffer',
	split = 'sbuffer',
	vsplit = 'vertical sbuffer',
	tab = 'tab sbuffer',
}

--- item の位置を開く
---@param item finder.Item
---@param cmd? finder.OpenCmd
function M.open(item, cmd)
	local bufnr = item.bufnr
	if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
		if not item.file then
			return
		end
		-- ファイルもバッファ番号に揃えると、開き方の分岐を buffer 系コマンドだけで済ませられる
		bufnr = vim.fn.bufadd(item.file)
		vim.bo[bufnr].buflisted = true
	end
	-- <C-o> で戻れるように jumplist に積む
	vim.cmd("normal! m'")
	vim.cmd(buffer_cmd[cmd or 'edit'] .. ' ' .. bufnr)
	if item.lnum then
		pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max((item.col or 1) - 1, 0) })
		vim.cmd('normal! zvzz')
	end
end

---@param title string
---@param items finder.Item[]
local function send_to_quickfix(title, items)
	local qf = {}
	for _, item in ipairs(items) do
		if item.file or item.bufnr then
			qf[#qf + 1] = {
				bufnr = item.bufnr,
				filename = item.file,
				lnum = item.lnum or 1,
				col = item.col or 1,
				text = item.text,
			}
		end
	end
	vim.fn.setqflist({}, ' ', { title = title, items = qf })
	vim.cmd.copen()
end

---@class finder.Finder
---@field opts finder.Opts
---@field items finder.Item[]
---@field texts string[] matchfuzzypos() に渡す items[i].text の写し
---@field index_of table<string, integer[]> 絞り込み対象の文字列から items の添字を引く。同じ文字列が複数あり得るため配列
---@field generation integer set_producer() のたびに増やし、中断した producer から遅れて届く候補を捨てる
---@field results { item: finder.Item, positions?: integer[] }[]
---@field line_to_result table<integer, integer>
---@field cursor integer 選択中の行 (1-based)
---@field query string
---@field loading boolean
---@field closed boolean
local Finder = {}
Finder.__index = Finder

---@param items finder.Item[]
function Finder:push(items)
	if self.closed then
		return
	end
	for _, item in ipairs(items) do
		local i = #self.items + 1
		local key = item.filter_text or item.text
		self.items[i] = item
		self.texts[i] = key
		local idxs = self.index_of[key]
		if idxs then
			idxs[#idxs + 1] = i
		else
			self.index_of[key] = { i }
		end
	end
	-- 非同期の source は細切れに push してくるため、まとめて再描画する
	if not self.timer:is_active() then
		self.timer:start(30, 0, vim.schedule_wrap(function()
			self:refresh(true)
		end))
	end
end

--- 候補を空にして producer から取り直す。nil なら空のままにする
---@param producer? fun(push: fun(items: finder.Item[]), done: fun()): fun()?
function Finder:set_producer(producer)
	if self.cancel_producer then
		self.cancel_producer()
		self.cancel_producer = nil
	end
	self.generation = self.generation + 1
	local generation = self.generation
	self.items, self.texts, self.index_of = {}, {}, {}
	self.loading = producer ~= nil
	self:refresh()
	if not producer then
		return
	end
	self.cancel_producer = producer(function(items)
		if generation == self.generation then
			self:push(items)
		end
	end, function()
		if generation ~= self.generation then
			return
		end
		self.loading = false
		if not self.closed then
			self:refresh(true)
		end
	end)
end

function Finder:filter()
	local results = {}
	if self.query == '' then
		for i = 1, math.min(#self.items, LIMIT) do
			results[i] = { item = self.items[i] }
		end
	else
		local res = vim.fn.matchfuzzypos(self.texts, self.query, { limit = LIMIT })
		-- 文字列のリストで渡すと Lua -> Vim の変換が軽い。代わりに text から item を引き直す
		local used = {}
		for i, text in ipairs(res[1]) do
			local n = (used[text] or 0) + 1
			used[text] = n
			results[i] = { item = self.items[self.index_of[text][n]], positions = res[2][i] }
		end
	end

	if self.opts.groups then
		-- スコア順を保ったままグループ順に並べ替える (table.sort は安定ソートではないため順位を添える)
		for i, r in ipairs(results) do
			r.rank = i
		end
		table.sort(results, function(a, b)
			local ga, gb = a.item.group or 0, b.item.group or 0
			if ga ~= gb then
				return ga < gb
			end
			return a.rank < b.rank
		end)
	end
	self.results = results
end

function Finder:render()
	local lines, marks = {}, {}
	self.line_to_result = {}
	local last_group
	for i, r in ipairs(self.results) do
		local item = r.item
		if self.opts.groups and item.group ~= last_group then
			last_group = item.group
			local g = self.opts.groups[item.group] or { title = '' }
			lines[#lines + 1] = '── ' .. g.title .. ' ──'
			marks[#marks + 1] = { #lines - 1, 0, #lines[#lines], g.hl or 'FinderGroup' }
		end
		local prefix = item.icon and (item.icon .. ' ') or ''
		lines[#lines + 1] = (prefix .. item.text):gsub('\n', ' ')
		self.line_to_result[#lines] = i
		local row = #lines - 1
		if item.icon_hl and item.icon then
			marks[#marks + 1] = { row, 0, #item.icon, item.icon_hl }
		end
		local key = item.filter_text or item.text
		for _, pos in ipairs(r.positions or {}) do
			-- matchfuzzypos() の位置は文字単位なのでバイト位置に直す
			local s = vim.str_byteindex(key, 'utf-32', pos, false)
			local e = vim.str_byteindex(key, 'utf-32', pos + 1, false)
			marks[#marks + 1] = { row, #prefix + s, #prefix + e, 'FinderMatch' }
		end
	end

	local buf = self.list_buf
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
	end
end

---@return finder.Item?
function Finder:selected()
	local i = self.line_to_result[self.cursor]
	return i and self.results[i].item or nil
end

--- 見出し行を飛ばして delta 件分カーソルを動かす。端では反対側に回り込む
---@param delta integer
function Finder:move(delta)
	local n = vim.api.nvim_buf_line_count(self.list_buf)
	local line = self.cursor
	for _ = 1, n do
		line = (line - 1 + delta) % n + 1
		if self.line_to_result[line] then
			break
		end
	end
	self:set_cursor(line)
end

---@param line integer
function Finder:set_cursor(line)
	self.cursor = line
	if self.line_to_result[line] then
		vim.api.nvim_win_set_cursor(self.list_win, { line, 0 })
	end
	self:update_footer()
	self:update_preview()
end

function Finder:update_footer()
	local i = self.line_to_result[self.cursor] or 0
	local footer = string.format(' %d/%d%s%s ', i, #self.results,
		#self.results < #self.items and (' (' .. #self.items .. ')') or '',
		self.loading and ' …' or '')
	vim.api.nvim_win_set_config(self.list_win, { footer = footer, footer_pos = 'right' })
end

---@param keep_selection? boolean 非同期 source の読み込み中に操作していても選択を見失わないようにする
function Finder:refresh(keep_selection)
	if self.closed then
		return
	end
	local prev = keep_selection and self:selected() or nil
	self:filter()
	self:render()
	local line
	for l, i in pairs(prev and self.line_to_result or {}) do
		if self.results[i].item == prev then
			line = l
			break
		end
	end
	if not line then
		self.cursor = 0
		self:move(1)
	else
		self:set_cursor(line)
	end
end

function Finder:update_preview()
	local win = self.preview_win
	if not win then
		return
	end
	local item = self:selected()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	local lines, ft = {}, nil
	if item and item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
		lines = vim.api.nvim_buf_get_lines(item.bufnr, 0, -1, false)
		ft = vim.bo[item.bufnr].filetype
	elseif item and item.file then
		local size = vim.fn.getfsize(item.file)
		if size > 1024 * 1024 then
			lines = { '(too large)' }
		elseif size >= 0 then
			lines = vim.fn.readfile(item.file, '')
			-- readfile() は NUL を改行に置き換える。改行を含む行は set_lines できないためバイナリ扱いにする
			if lines[1] and lines[1]:find('\n') then
				lines = { '(binary)' }
			else
				ft = vim.filetype.match({ filename = item.file })
			end
		end
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	if ft then
		-- filetype を設定すると LSP や ftplugin まで起動してしまうため、ハイライトだけを有効にする
		local lang = vim.treesitter.language.get_lang(ft)
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start(buf, lang)
		else
			vim.bo[buf].syntax = ft
		end
	end
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_config(win, {
		title = item and (item.file and (' ' .. relpath(item.file) .. ' ')) or '',
	})
	if item and item.lnum then
		pcall(vim.api.nvim_win_set_cursor, win, { item.lnum, math.max((item.col or 1) - 1, 0) })
		vim.api.nvim_win_call(win, function()
			vim.cmd('normal! zz')
		end)
	end
end

---@param cmd 'down'|'up'
function Finder:scroll_preview(cmd)
	if self.preview_win then
		vim.api.nvim_win_call(self.preview_win, function()
			vim.cmd.normal({ args = { vim.keycode(cmd == 'down' and '<C-d>' or '<C-u>') }, bang = true })
		end)
	end
end

---@param on_done? fun() ウィンドウを閉じて元のウィンドウに戻ってから呼ぶ
function Finder:close(on_done)
	if self.closed then
		return
	end
	self.closed = true
	for _, timer in ipairs({ self.timer, self.input_timer }) do
		timer:stop()
		timer:close()
	end
	if self.cancel_producer then
		self.cancel_producer()
	end
	for _, win in ipairs(self:windows()) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	vim.cmd.stopinsert()
	-- stopinsert は mapping を抜けた後に効くため、カーソル操作はその後に行う
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(self.origin_win) then
			vim.api.nvim_set_current_win(self.origin_win)
			pcall(vim.api.nvim_win_set_cursor, self.origin_win, self.origin_cursor)
		end
		if on_done then
			on_done()
		elseif self.opts.on_cancel then
			self.opts.on_cancel()
		end
	end)
end

---@param cmd finder.OpenCmd
function Finder:accept(cmd)
	local item = self:selected()
	if not item then
		return
	end
	self:close(function()
		if self.opts.on_select then
			self.opts.on_select(item, cmd)
		else
			M.open(item, cmd)
		end
	end)
end

function Finder:open_windows()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local with_preview = self.opts.preview ~= false and width >= 100
	local list_width = with_preview and math.floor(width * 0.45) or width

	local function float(buf, cfg)
		-- 枠線の分 (上下左右 1 ずつ) をサイズから差し引く
		return vim.api.nvim_open_win(buf, false, vim.tbl_extend('force', {
			relative = 'editor',
			style = 'minimal',
			border = 'single',
		}, cfg, { width = cfg.width - 2, height = cfg.height - 2 }))
	end

	local function scratch()
		local buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].bufhidden = 'wipe'
		-- filetype が空だと BufEnter で txt が設定されるなど、他の設定の対象になってしまうため明示する
		vim.bo[buf].filetype = 'finder'
		return buf
	end

	-- 入力欄は追加の入力欄を上から並べ、最後に絞り込み欄を置く
	self.input_wins = {}
	local inputs = self.opts.inputs or {}
	for i, input in ipairs(inputs) do
		local buf = scratch()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { input.default or '' })
		self.input_wins[i] = float(buf, {
			row = row + 3 * (i - 1), col = col, width = list_width, height = 3,
			title = ' ' .. input.title .. ' ',
		})
	end
	local prompt_row = row + 3 * #inputs
	self.prompt_buf = scratch()
	self.list_buf = scratch()
	self.prompt_win = float(self.prompt_buf, {
		row = prompt_row, col = col, width = list_width, height = 3,
		title = ' ' .. (#inputs > 0 and 'Filter' or self.opts.title) .. ' ',
	})
	self.list_win = float(self.list_buf, {
		row = prompt_row + 3, col = col, width = list_width, height = height - 3 * (#inputs + 1),
	})
	vim.wo[self.list_win].cursorline = true
	if with_preview then
		self.preview_win = float(vim.api.nvim_create_buf(false, true), {
			row = row, col = col + list_width, width = width - list_width, height = height,
		})
		vim.wo[self.preview_win].number = true
		vim.wo[self.preview_win].cursorline = true
	end
	self:focus_input(self.opts.focus and self.input_wins[self.opts.focus] or self.prompt_win)
end

---@return integer[] 入力欄を上から順に並べたもの
function Finder:prompt_wins()
	local wins = vim.list_extend({}, self.input_wins)
	wins[#wins + 1] = self.prompt_win
	return wins
end

---@return integer[]
function Finder:windows()
	local wins = self:prompt_wins()
	wins[#wins + 1] = self.list_win
	wins[#wins + 1] = self.preview_win
	return wins
end

---@param win integer
function Finder:focus_input(win)
	vim.api.nvim_set_current_win(win)
	-- 入力の続きをすぐ打てるよう行末に置く
	vim.api.nvim_win_set_cursor(win, { 1, #vim.api.nvim_get_current_line() })
end

--- 入力欄を上から順に巡回する
function Finder:cycle_input()
	local wins = self:prompt_wins()
	local current = vim.api.nvim_get_current_win()
	for i, win in ipairs(wins) do
		if win == current then
			self:focus_input(wins[i % #wins + 1])
			return
		end
	end
end

function Finder:set_keymaps()
	for _, win in ipairs(self:prompt_wins()) do
		self:set_prompt_keymaps(vim.api.nvim_win_get_buf(win))
	end

	vim.api.nvim_create_autocmd('TextChangedI', {
		buffer = self.prompt_buf,
		callback = function()
			self.query = vim.api.nvim_get_current_line()
			self:refresh()
		end,
	})
	for i, input in ipairs(self.opts.inputs or {}) do
		vim.api.nvim_create_autocmd('TextChangedI', {
			buffer = vim.api.nvim_win_get_buf(self.input_wins[i]),
			callback = function()
				local value = vim.api.nvim_get_current_line()
				-- 外部コマンドを打鍵ごとに起動し直すと重いため、入力が止まるまで待つ
				self.input_timer:stop()
				self.input_timer:start(200, 0, vim.schedule_wrap(function()
					if not self.closed then
						input.on_change(value, self)
					end
				end))
			end,
		})
	end
end

---@param buf integer
function Finder:set_prompt_keymaps(buf)
	local function map(modes, lhs, fn)
		vim.keymap.set(modes, lhs, fn, { buffer = buf, nowait = true })
	end
	for _, lhs in ipairs({ '<C-n>', '<Down>', '<Tab>' }) do
		map('i', lhs, function() self:move(1) end)
	end
	for _, lhs in ipairs({ '<C-p>', '<Up>', '<S-Tab>' }) do
		map('i', lhs, function() self:move(-1) end)
	end
	map('n', 'j', function() self:move(1) end)
	map('n', 'k', function() self:move(-1) end)
	map({ 'i', 'n' }, '<CR>', function() self:accept('edit') end)
	map({ 'i', 'n' }, '<C-s>', function() self:accept('split') end)
	map({ 'i', 'n' }, '<C-v>', function() self:accept('vsplit') end)
	map({ 'i', 'n' }, '<C-t>', function() self:accept('tab') end)
	-- <C-u> は入力欄の行消去に残しておきたいので、プレビューのスクロールには使わない
	map({ 'i', 'n' }, '<C-f>', function() self:scroll_preview('down') end)
	map({ 'i', 'n' }, '<C-b>', function() self:scroll_preview('up') end)
	map({ 'i', 'n' }, '<C-q>', function()
		local items = vim.tbl_map(function(r) return r.item end, self.results)
		self:close(function() send_to_quickfix(self.opts.title, items) end)
	end)
	map({ 'i', 'n' }, '<Esc>', function() self:close() end)
	map({ 'i', 'n' }, '<C-c>', function() self:close() end)
	map('n', 'q', function() self:close() end)
	map({ 'i', 'n' }, '<C-g>', function() self:cycle_input() end)

	-- マウスなどで別ウィンドウへ移ったときにフロートが残らないようにする。
	-- 入力欄どうしの移動でも WinLeave は起きるため、移動先が自分のウィンドウかを確かめてから閉じる
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		callback = function()
			vim.schedule(function()
				if not vim.tbl_contains(self:windows(), vim.api.nvim_get_current_win()) then
					self:close()
				end
			end)
		end,
	})
end

---@param opts finder.Opts
---@return finder.Finder テストから状態を検査できるように返す
function M.start(opts)
	local self = setmetatable({
		opts = opts,
		items = {},
		texts = {},
		index_of = {},
		results = {},
		line_to_result = {},
		cursor = 0,
		query = '',
		loading = false,
		closed = false,
		generation = 0,
		timer = vim.uv.new_timer(),
		input_timer = vim.uv.new_timer(),
		origin_win = vim.api.nvim_get_current_win(),
		origin_cursor = vim.api.nvim_win_get_cursor(0),
	}, Finder)

	self:open_windows()
	self:set_keymaps()
	self:push(opts.items or {})
	self:refresh()
	-- 既定値の入った入力欄でも続きを打てるよう、行末から挿入する
	vim.cmd('startinsert!')

	if opts.producer then
		self:set_producer(opts.producer)
	end
	for _, input in ipairs(opts.inputs or {}) do
		input.on_change(input.default or '', self)
	end
	return self
end

--- 外部コマンドの出力を 1 行ずつ item に変換して流し込む producer を作る
---@param cmd string[]
---@param parse fun(line: string): finder.Item?
---@return fun(push: fun(items: finder.Item[]), done: fun()): fun()
function M.command(cmd, parse)
	return function(push, done)
		local partial = ''
		local proc = vim.system(cmd, {
			stdout = function(_, data)
				if not data then
					return
				end
				-- 出力は行の途中で区切られて届くため、最後の不完全な行は次回に持ち越す
				local lines = vim.split(partial .. data, '\n', { plain = true })
				partial = table.remove(lines)
				vim.schedule(function()
					local items = {}
					for _, line in ipairs(lines) do
						items[#items + 1] = parse(line)
					end
					push(items)
				end)
			end,
		}, vim.schedule_wrap(function()
			done()
		end))
		return function()
			proc:kill('sigterm')
		end
	end
end

--- vim.ui.select() の代わりに使う。LSP の code action などもこのファインダーで選べる
---@param items any[]
---@param opts { prompt?: string, format_item?: fun(item: any): string }
---@param on_choice fun(item: any?, idx: integer?)
function M.ui_select(items, opts, on_choice)
	opts = opts or {}
	local format = opts.format_item or tostring
	local fitems = {}
	for i, it in ipairs(items) do
		fitems[i] = { text = format(it), data = i }
	end
	M.start({
		title = opts.prompt or 'Select',
		items = fitems,
		preview = false,
		on_select = function(item)
			on_choice(items[item.data], item.data)
		end,
		on_cancel = function()
			on_choice(nil, nil)
		end,
	})
end

return M
