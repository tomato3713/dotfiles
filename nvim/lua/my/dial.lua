-- <C-a>/<C-x> の拡張。数値だけでなく日付・定数の組・命名規則なども増減・切り替えする
-- dps-dial.vim の置き換え。Deno に依存せず、使っている機能だけを Lua で実装している

---@class dial.Augend
---@field find fun(line: string): { [1]: integer, [2]: integer }[] 対象になる範囲の一覧。開始は 0-based、終了は含まない
---@field add fun(text: string, delta: integer, offset: integer): string, integer? 新しい文字列と、その中でのカーソル位置を返す。offset はカーソルの位置で、カーソルより後ろの候補なら -1

local M = {}

---@param line string
---@param pattern string
---@return { [1]: integer, [2]: integer }[]
local function find_all(line, pattern)
	local ranges, init = {}, 1
	while true do
		local s, e = line:find(pattern, init)
		if not s then
			return ranges
		end
		ranges[#ranges + 1] = { s - 1, e }
		init = e + 1
	end
end

---@param line string
---@param s integer 0-based
---@param e integer
---@return boolean
local function is_word(line, s, e)
	local before = line:sub(s, s)
	local after = line:sub(e + 1, e + 1)
	return not before:match('[%w_]') and not after:match('[%w_]')
end

M.augends = {}

--- 10 進数の整数
---@return dial.Augend
function M.augends.decimal()
	return {
		find = function(line)
			local ranges = {}
			for _, r in ipairs(find_all(line, '%d+')) do
				local s = r[1]
				-- '-' の前が単語の一部なら引き算 (a-1 など) とみなし、負の数として扱わない
				if line:sub(s, s) == '-' and not line:sub(s - 1, s - 1):match('[%w_]') then
					s = s - 1
				end
				ranges[#ranges + 1] = { s, r[2] }
			end
			return ranges
		end,
		add = function(text, delta)
			local n = tonumber(text) + delta
			local digits = text:gsub('^%-', '')
			-- 007 のようにゼロ埋めされた数は桁数を保つ
			if digits:match('^0%d') and n >= 0 then
				return string.format('%0' .. #digits .. 'd', n)
			end
			return string.format('%d', n)
		end,
	}
end

---@param year integer
---@param month integer
---@return integer
local function days_in_month(year, month)
	-- 翌月の 0 日は今月の末日になる
	return os.date('*t', os.time({ year = year, month = month + 1, day = 0, hour = 12 })).day
end

--- YYYY/MM/DD 形式の日付。カーソルが年・月・日のどこにあるかで増減する単位を変える
---@return dial.Augend
function M.augends.date_slash()
	return {
		find = function(line)
			return find_all(line, '%d%d%d%d/%d%d/%d%d')
		end,
		add = function(text, delta, offset)
			local y, m, d = text:match('^(%d+)/(%d+)/(%d+)$')
			y, m, d = tonumber(y), tonumber(m), tonumber(d)
			if offset >= 0 and offset <= 4 then
				y = y + delta
			elseif offset >= 5 and offset <= 7 then
				local months = y * 12 + (m - 1) + delta
				y, m = math.floor(months / 12), months % 12 + 1
			else
				-- 日の増減は月や年の繰り上がりを os.time() に任せる
				local t = os.date('*t', os.time({ year = y, month = m, day = d + delta, hour = 12 }))
				return string.format('%04d/%02d/%02d', t.year, t.month, t.day), offset >= 0 and offset or #text - 1
			end
			-- 1/31 の翌月が 3/3 にならないよう、月末を超えたら月末に揃える
			d = math.min(d, days_in_month(y, m))
			return string.format('%04d/%02d/%02d', y, m, d), offset
		end,
	}
end

--- 決まった語の組を順に切り替える (true/false など)
---@param elements string[]
---@param opts? { cyclic?: boolean, word?: boolean } cyclic: 端で反対側に回り込む (既定 true)。word: 単語単位でだけ一致させる (既定 true)
---@return dial.Augend
function M.augends.constant(elements, opts)
	opts = opts or {}
	local cyclic = opts.cyclic ~= false
	local word = opts.word ~= false
	local index = {}
	for i, el in ipairs(elements) do
		index[el] = i
	end
	return {
		find = function(line)
			local ranges = {}
			for _, el in ipairs(elements) do
				local init = 1
				while true do
					local s, e = line:find(el, init, true)
					if not s then
						break
					end
					if not word or is_word(line, s - 1, e) then
						ranges[#ranges + 1] = { s - 1, e }
					end
					init = e + 1
				end
			end
			return ranges
		end,
		add = function(text, delta)
			local i = index[text] - 1 + delta
			if cyclic then
				i = i % #elements
			elseif i < 0 or i >= #elements then
				return text
			end
			return elements[i + 1]
		end,
	}
end

--- camelCase と snake_case を切り替える
---@return dial.Augend
function M.augends.case()
	local function is_camel(text)
		return text:match('^%l[%w]*$') ~= nil and text:find('%u') ~= nil
	end
	local function is_snake(text)
		return text:match('^%l[%l%d_]*$') ~= nil and text:find('_') ~= nil
	end
	return {
		find = function(line)
			return vim.tbl_filter(function(r)
				local text = line:sub(r[1] + 1, r[2])
				return is_camel(text) or is_snake(text)
			end, find_all(line, '[%a_][%w_]*'))
		end,
		add = function(text, delta)
			-- 2 種類を巡回するので、偶数回なら元に戻る
			if delta % 2 == 0 then
				return text
			end
			if is_camel(text) then
				return (text:gsub('%u', function(c) return '_' .. c:lower() end))
			end
			return (text:gsub('_(%w)', function(c) return c:upper() end))
		end,
	}
end

--- 数値の配列を辞書順で比べる
---@param a number[]
---@param b number[]
---@return boolean
local function less(a, b)
	for i = 1, #a do
		if a[i] ~= b[i] then
			return a[i] < b[i]
		end
	end
	return false
end

---@type { default: dial.Augend[], filetype: table<string, dial.Augend[]> }
local config = { default = {}, filetype = {} }

---@return dial.Augend[] filetype 固有のものを優先する
local function augends_for_buffer()
	return vim.list_extend(vim.list_extend({}, config.filetype[vim.bo.filetype] or {}), config.default)
end

--- 対象を 1 つ選ぶ。カーソルを含むもの、カーソルより後ろのものの順に優先し、
--- その中では開始位置が前のもの、同じなら長いもの、それも同じなら augends で先に書いたものを選ぶ。
--- 長いものを優先するのは、日付の年と数値のように一方が他方を含むとき、より意味のある単位で扱うため
---@param line string
---@param col integer 0-based のカーソル位置
---@param augends dial.Augend[]
---@param range? { [1]: integer, [2]: integer } 指定するとこの範囲で始まるものだけを選ぶ (visual mode 用)
---@return { augend: dial.Augend, s: integer, e: integer }?
local function pick(line, col, augends, range)
	local best, best_key
	for priority, augend in ipairs(augends) do
		for _, r in ipairs(augend.find(line)) do
			local s, e = r[1], r[2]
			local rank
			if range then
				rank = (s >= range[1] and s < range[2]) and 0 or nil
			elseif s <= col and col < e then
				rank = 0
			elseif s > col then
				rank = 1
			end
			if rank then
				-- 小さいほど優先する。長さは負にして長いほど小さくする
				local key = { rank, s, -(e - s), priority }
				if not best_key or less(key, best_key) then
					best, best_key = { augend = augend, s = s, e = e }, key
				end
			end
		end
	end
	return best
end

--- row 行目の対象を delta だけ増減する
---@param row integer 1-based
---@param col integer 0-based
---@param delta integer
---@param range? { [1]: integer, [2]: integer }
---@return integer? 変更した場合、新しいカーソル列
local function apply(row, col, delta, range)
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
	local hit = pick(line, col, augends_for_buffer(), range)
	if not hit then
		return nil
	end
	local text = line:sub(hit.s + 1, hit.e)
	local offset = (not range and col >= hit.s) and (col - hit.s) or -1
	local new, new_offset = hit.augend.add(text, delta, offset)
	if new ~= text then
		vim.api.nvim_buf_set_text(0, row - 1, hit.s, row - 1, hit.e, { new })
	end
	return hit.s + (new_offset or (#new - 1))
end

-- . で繰り返したときにも同じ量だけ増減できるよう、最後の操作を覚えておく
local last_delta = 1

--- operatorfunc から呼ばれる。. による繰り返しもここを通る
function M._operatorfunc()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local new_col = apply(row, col, last_delta)
	if new_col then
		vim.api.nvim_win_set_cursor(0, { row, new_col })
	end
end

--- normal mode の <C-a>/<C-x> 用。expr mapping として使う
---@param sign 1|-1
---@return fun(): string
function M.normal(sign)
	return function()
		last_delta = sign * vim.v.count1
		vim.o.operatorfunc = "v:lua.require'my.dial'._operatorfunc"
		-- g@ を経由すると . で繰り返せる
		return 'g@l'
	end
end

--- visual mode の <C-a>/<C-x> 用。選択範囲の各行で、範囲内の最初の対象を増減する
---@param sign 1|-1
---@param progressive boolean true なら g<C-a> のように、変更した行ごとに増減量を 1 倍、2 倍…と増やす
---@return fun()
function M.visual(sign, progressive)
	return function()
		local delta = sign * vim.v.count1
		local mode = vim.fn.mode()
		local p1, p2 = vim.fn.getpos('v'), vim.fn.getpos('.')
		local srow, erow = math.min(p1[2], p2[2]), math.max(p1[2], p2[2])
		local scol, ecol = math.min(p1[3], p2[3]) - 1, math.max(p1[3], p2[3])
		local first = (p1[2] < p2[2] or (p1[2] == p2[2] and p1[3] <= p2[3])) and p1 or p2
		local last = first == p1 and p2 or p1
		local changed = 0
		for row = srow, erow do
			local range
			if mode == 'V' then
				range = { 0, math.huge }
			elseif mode == 'v' then
				range = { row == srow and first[3] - 1 or 0, row == erow and last[3] or math.huge }
			else
				range = { scol, ecol }
			end
			local n = progressive and (changed + 1) or 1
			if apply(row, 0, delta * n, range) then
				changed = changed + 1
			end
		end
		-- 組み込みの visual <C-a> と同じく、選択を抜けて先頭に戻る
		vim.cmd.normal({ args = { vim.keycode('<Esc>') }, bang = true })
		vim.api.nvim_win_set_cursor(0, { srow, mode == 'V' and 0 or (mode == 'v' and first[3] - 1 or scol) })
	end
end

---@param opts { augends: dial.Augend[], filetype?: table<string, dial.Augend[]> }
function M.setup(opts)
	config.default = opts.augends
	config.filetype = opts.filetype or {}

	vim.keymap.set('n', '<C-a>', M.normal(1), { expr = true, desc = 'dial: increment' })
	vim.keymap.set('n', '<C-x>', M.normal(-1), { expr = true, desc = 'dial: decrement' })
	vim.keymap.set('x', '<C-a>', M.visual(1, false), { desc = 'dial: increment' })
	vim.keymap.set('x', '<C-x>', M.visual(-1, false), { desc = 'dial: decrement' })
	vim.keymap.set('x', 'g<C-a>', M.visual(1, true), { desc = 'dial: increment progressively' })
	vim.keymap.set('x', 'g<C-x>', M.visual(-1, true), { desc = 'dial: decrement progressively' })
end

return M
