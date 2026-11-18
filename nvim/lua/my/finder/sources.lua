local finder = require('my.finder')

local M = {}

local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

---@param path string
---@return finder.Item
local function file_item(path)
	local item = { text = finder.relpath(path), file = path }
	if has_devicons then
		item.icon, item.icon_hl = devicons.get_icon(path, nil, { default = true })
	end
	return item
end

-- 依存ディレクトリやビルド成果物は .gitignore に無くても候補から外す
local ignored_dirs = { '.git', 'node_modules', 'vendor', '.next', '.vscode', 'tmp' }

function M.files()
	local cmd = { 'rg', '--files', '--hidden' }
	for _, dir in ipairs(ignored_dirs) do
		vim.list_extend(cmd, { '--glob', '!' .. dir })
	end
	finder.start({
		title = 'Files',
		producer = finder.command(cmd, function(line)
			return line ~= '' and file_item(line) or nil
		end),
	})
end

--- 上の入力欄の内容で rg を実行し直し、下の入力欄で結果をファイルパスだけを対象に絞り込む
---@param word? string 検索パターンの初期値。空なら検索パターンの入力から始める
---@param dir? string 検索するディレクトリ。省略時はカレントディレクトリ
function M.grep(word, dir)
	word = word or ''
	-- 起動時のディレクトリに固定する。:tcd などで後から変わっても、表示と検索対象と開くファイルがずれないように
	local cwd = dir or vim.fn.getcwd()
	finder.start({
		title = 'Grep',
		inputs = { {
			title = 'Grep: ' .. vim.fn.fnamemodify(cwd, ':~'),
			default = word,
			on_change = function(pattern, f)
				if pattern == '' then
					f:set_producer(nil)
					return
				end
				f:set_producer(finder.command(
					{ 'rg', '--smart-case', '--line-number', '--column', '--no-heading', '--color', 'never', '--', pattern },
					function(line)
						local file, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
						if not file then
							return nil
						end
						return {
							text = string.format('%s:%s: %s', file, lnum, vim.trim(text)),
							-- 中身は rg のパターンで絞れるので、絞り込み欄はファイルの特定に使う
							filter_text = file,
							file = vim.fs.joinpath(cwd, file),
							lnum = tonumber(lnum),
							col = tonumber(col),
						}
					end,
					{ cwd = cwd }
				))
			end,
		} },
		focus = word == '' and 1 or nil,
	})
end

--- JunkDaily / JunkMonthly / JunkNote のメモ一覧。最近更新したものから並べる
function M.junkfiles()
	local junkfile = require('my.junkfile')
	local root = junkfile.dir()
	local files = {}
	for name, type in vim.fs.dir(root, { depth = math.huge }) do
		if type == 'file' then
			local path = vim.fs.joinpath(root, name)
			local stat = vim.uv.fs_stat(path)
			files[#files + 1] = { name = name, path = path, mtime = stat and stat.mtime.sec or 0 }
		end
	end
	table.sort(files, function(a, b)
		return a.mtime > b.mtime
	end)
	finder.start({
		title = 'Junkfiles',
		items = vim.tbl_map(function(f)
			local item = file_item(f.path)
			-- 置き場所のパスは共通なので、topics/perl.md や 2026/11/main.md の形で見せる
			item.text = f.name
			return item
		end, files),
	})
end

--- JunkDaily / JunkMonthly / JunkNote のメモの中身を grep する
function M.junkgrep()
	M.grep('', require('my.junkfile').dir())
end

--- 最近使ったファイル (mr.vim)
function M.mru()
	-- mr.vim は BufReadPre などで遅延読み込みされるため、起動直後でも使えるように読み込んでおく
	pcall(vim.fn['dein#source'], 'mr.vim')
	local items = {}
	for _, path in ipairs(vim.fn['mr#mru#list']()) do
		if vim.fn.filereadable(path) == 1 then
			items[#items + 1] = file_item(path)
		end
	end
	finder.start({ title = 'MRU', items = items })
end

function M.buffers()
	local current = vim.api.nvim_get_current_buf()
	local infos = vim.fn.getbufinfo({ buflisted = 1 })
	-- 直前に使ったバッファを先頭にする。今いるバッファは選ぶ意味が薄いので末尾へ
	table.sort(infos, function(a, b)
		if (a.bufnr == current) ~= (b.bufnr == current) then
			return b.bufnr == current
		end
		return a.lastused > b.lastused
	end)
	local items = {}
	for _, info in ipairs(infos) do
		local item = file_item(info.name ~= '' and info.name or '[No Name]')
		item.file = nil
		item.bufnr = info.bufnr
		item.lnum = info.lnum
		items[#items + 1] = item
	end
	finder.start({ title = 'Buffers', items = items })
end

function M.marks()
	local items = {}
	local function add(mark)
		-- 'a や 'A などの英字マークだけを対象にする。'[ や '" などの自動マークは選ぶ機会が少ないため
		if not mark.mark:match("^'%a$") then
			return
		end
		local bufnr, lnum, col = mark.pos[1], mark.pos[2], mark.pos[3]
		local name = mark.file or vim.api.nvim_buf_get_name(bufnr)
		local line = vim.api.nvim_buf_is_loaded(bufnr)
			and (vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or '')
			or ''
		items[#items + 1] = {
			text = string.format('%s %s:%d: %s', mark.mark:sub(2), finder.relpath(name), lnum, vim.trim(line)),
			bufnr = bufnr ~= 0 and bufnr or nil,
			-- 空文字のまま渡すと open() の bufadd('') が新しい空バッファを作ってしまう
			file = name ~= '' and name or nil,
			lnum = lnum,
			col = col,
		}
	end
	for _, mark in ipairs(vim.fn.getmarklist(vim.api.nvim_get_current_buf())) do
		add(mark)
	end
	for _, mark in ipairs(vim.fn.getmarklist()) do
		add(mark)
	end
	finder.start({ title = 'Marks', items = items })
end

function M.tabs()
	local items = {}
	for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local names = {}
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			if vim.api.nvim_win_get_config(win).relative == '' then
				local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
				names[#names + 1] = name ~= '' and vim.fn.fnamemodify(name, ':t') or '[No Name]'
			end
		end
		local win = vim.api.nvim_tabpage_get_win(tab)
		items[#items + 1] = {
			text = string.format('%d: %s', nr, table.concat(names, ', ')),
			bufnr = vim.api.nvim_win_get_buf(win),
			lnum = vim.api.nvim_win_get_cursor(win)[1],
			data = nr,
		}
	end
	finder.start({
		title = 'Tabs',
		items = items,
		on_select = function(item)
			vim.cmd.tabnext(item.data)
		end,
	})
end

function M.help()
	-- getcompletion('', 'help') は空文字だと一部しか返さないため、tags ファイルを直接読む
	local items, seen = {}, {}
	for _, tags in ipairs(vim.api.nvim_get_runtime_file('doc/tags*', true)) do
		for _, line in ipairs(vim.fn.readfile(tags)) do
			local tag = line:match('^([^\t]+)\t')
			if tag and not seen[tag] and not tag:match('^!_TAG_') then
				seen[tag] = true
				items[#items + 1] = { text = tag }
			end
		end
	end
	finder.start({
		title = 'Help',
		items = items,
		preview = false,
		on_select = function(item)
			vim.cmd({ cmd = 'help', args = { item.text } })
		end,
	})
end

function M.colorschemes()
	local items = {}
	for _, name in ipairs(vim.fn.getcompletion('', 'color')) do
		items[#items + 1] = { text = name }
	end
	finder.start({
		title = 'Colorschemes',
		items = items,
		preview = false,
		on_select = function(item)
			vim.cmd.colorscheme(item.text)
		end,
	})
end

local severity_icon = {
	[vim.diagnostic.severity.ERROR] = { 'E', 'DiagnosticError' },
	[vim.diagnostic.severity.WARN] = { 'W', 'DiagnosticWarn' },
	[vim.diagnostic.severity.INFO] = { 'I', 'DiagnosticInfo' },
	[vim.diagnostic.severity.HINT] = { 'H', 'DiagnosticHint' },
}

function M.diagnostics()
	local diagnostics = vim.diagnostic.get()
	table.sort(diagnostics, function(a, b)
		return a.severity < b.severity
	end)
	local items = {}
	for _, d in ipairs(diagnostics) do
		local icon = severity_icon[d.severity]
		items[#items + 1] = {
			text = string.format('%s:%d: %s', finder.relpath(vim.api.nvim_buf_get_name(d.bufnr)), d.lnum + 1,
				d.message:gsub('\n', ' ')),
			icon = icon[1],
			icon_hl = icon[2],
			bufnr = d.bufnr,
			lnum = d.lnum + 1,
			col = d.col + 1,
		}
	end
	finder.start({ title = 'Diagnostics', items = items })
end

return M
