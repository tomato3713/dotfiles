-- vim.notify の置き換え。右上に通知を積み重ねて表示し、一定時間で消す。
-- nvim-notify はアニメーションや多くの表示形式を持つが、使っているのは「出して消える」だけなので自前で持つ
local M = {}

local levels = vim.log.levels

local level_names = {
	[levels.TRACE] = 'TRACE',
	[levels.DEBUG] = 'DEBUG',
	[levels.INFO] = 'INFO',
	[levels.WARN] = 'WARN',
	[levels.ERROR] = 'ERROR',
}

local level_hl = {
	[levels.TRACE] = 'Comment',
	[levels.DEBUG] = 'Comment',
	[levels.INFO] = 'DiagnosticInfo',
	[levels.WARN] = 'DiagnosticWarn',
	[levels.ERROR] = 'DiagnosticError',
}

M.config = {
	timeout = 3000,
	-- エディタ幅に対する通知の最大幅の割合
	max_width = 0.3,
}

---@class my.notify.Record
---@field msg string
---@field level integer
---@field title? string
---@field time integer

---@type my.notify.Record[]
M.history = {}

--- 表示中の通知。上から順に並ぶ
---@type { win: integer, height: integer }[]
local shown = {}

--- nvim-notify に合わせて 'error' のような文字列のレベルも受け付ける
---@param level? integer|string
---@return integer
local function normalize_level(level)
	if type(level) == 'string' then
		return levels[level:upper()] or levels.INFO
	end
	return level or levels.INFO
end

--- 通知を上から詰めて並べ直す。tabline が出ているときはその下から並べる
local function layout()
	local tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr('$') > 1)
	local row = tabline and 1 or 0
	for _, n in ipairs(shown) do
		vim.api.nvim_win_set_config(n.win, { relative = 'editor', anchor = 'NE', row = row, col = vim.o.columns })
		-- 上下の枠線の分を足す
		row = row + n.height + 2
	end
end

---@param win integer
local function close(win)
	for i, n in ipairs(shown) do
		if n.win == win then
			table.remove(shown, i)
			break
		end
	end
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	layout()
end

---@param record my.notify.Record
---@param timeout integer
local function show(record, timeout)
	local lines = vim.split(record.msg, '\n', { trimempty = true })
	if #lines == 0 then
		return
	end
	local max_width = math.max(math.floor(vim.o.columns * M.config.max_width), 10)
	local width = 1
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = math.min(width, max_width)
	-- 折り返しで増える行数も含めた高さにする
	local height = 0
	for _, l in ipairs(lines) do
		height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(l) / width))
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].bufhidden = 'wipe'
	local hl = level_hl[record.level] or 'Normal'
	local win = vim.api.nvim_open_win(buf, false, {
		relative = 'editor',
		anchor = 'NE',
		row = 0,
		col = vim.o.columns,
		width = width,
		height = height,
		style = 'minimal',
		-- タイトルと積み重ねの間隔は枠線がある前提なので、winborder が無いときも枠線を付ける
		border = (vim.o.winborder == '' or vim.o.winborder == 'none') and 'single' or nil,
		title =' ' .. (record.title or level_names[record.level] or 'INFO') .. ' ',
		focusable = false,
		-- noice のポップアップなどよりも手前に出す
		zindex = 250,
		noautocmd = true,
	})
	vim.wo[win].wrap = true
	vim.wo[win].winhighlight = ('FloatBorder:%s,FloatTitle:%s'):format(hl, hl)

	table.insert(shown, { win = win, height = height })
	layout()
	vim.defer_fn(function() close(win) end, timeout)
end

--- vim.notify と同じ引数を取る
---@param msg string
---@param level? integer|string
---@param opts? { title?: string, timeout?: integer }
function M.notify(msg, level, opts)
	opts = opts or {}
	---@type my.notify.Record
	local record = { msg = tostring(msg), level = normalize_level(level), title = opts.title, time = os.time() }
	table.insert(M.history, record)
	-- vim.notify は libuv のコールバックなど API を呼べない文脈からも呼ばれるため、表示は後回しにする
	vim.schedule(function() show(record, opts.timeout or M.config.timeout) end)
end

--- 表示中の通知をすべて閉じる
function M.dismiss()
	for _, n in ipairs(vim.list_slice(shown)) do
		close(n.win)
	end
end

--- 履歴を新しいバッファに一覧する
function M.open_history()
	local lines = {}
	for _, r in ipairs(M.history) do
		local head = ('[%s] %s'):format(os.date('%H:%M:%S', r.time), level_names[r.level] or '')
		if r.title then
			head = head .. ' ' .. r.title
		end
		for i, l in ipairs(vim.split(r.msg, '\n')) do
			lines[#lines + 1] = (i == 1 and head .. ': ' or string.rep(' ', #head + 2)) .. l
		end
	end
	vim.cmd.new()
	vim.bo.buftype = 'nofile'
	vim.bo.bufhidden = 'wipe'
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.modifiable = false
end

---@param config? { timeout?: integer, max_width?: number }
function M.setup(config)
	M.config = vim.tbl_extend('force', M.config, config or {})
	vim.notify = M.notify
	vim.api.nvim_create_user_command('Notifications', M.open_history, { desc = 'show notification history' })
	vim.api.nvim_create_user_command('NotificationsClear', function()
		M.history = {}
		M.dismiss()
	end, { desc = 'clear notification history' })
end

return M
