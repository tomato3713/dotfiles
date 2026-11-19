local gitlink = require('my.gitlink')

--- 選択範囲 (visual でなければカーソル行) の行番号を返す
---@return integer lstart, integer lend
local function line_range()
	local l1, l2 = vim.fn.line('v'), vim.fn.line('.')
	return math.min(l1, l2), math.max(l1, l2)
end

---@param url? string
---@param err? string
local function yank(url, err)
	if not url then
		vim.notify('gitlink: ' .. err, vim.log.levels.WARN)
		return
	end
	vim.fn.setreg('+', url)
	vim.notify(url)
end

---@param url? string
---@param err? string
local function open(url, err)
	if not url then
		vim.notify('gitlink: ' .. err, vim.log.levels.WARN)
		return
	end
	vim.ui.open(url)
end

-- yank the URL of the current or selected line.
vim.keymap.set({ 'n', 'x' }, '<leader>gy', function() yank(gitlink.buf_url(line_range())) end,
	{ desc = 'yank permalink of lines' })
-- yank the URL of the current buffer file.
vim.keymap.set('n', '<leader>gf', function() yank(gitlink.buf_url()) end, { desc = 'yank permalink of file' })
-- open browser in cursor line or selected lines.
vim.keymap.set({ 'n', 'x' }, '<leader>gb', function() open(gitlink.buf_url(line_range())) end,
	{ desc = 'open permalink of lines' })

-- repository home page url
vim.keymap.set('n', '<leader>gY', function() yank(gitlink.repo_url()) end, { desc = 'yank repository url' })
vim.keymap.set('n', '<leader>gB', function() open(gitlink.repo_url()) end, { desc = 'open repository url' })

--- URL と選択したテキストを、format で整形してクリップボードに入れる
---@param format fun(url: string, filename: string, lines: string[]): string
local function yank_with_text(format)
	return function()
		local lstart, lend = line_range()
		local url, err = gitlink.buf_url(lstart, lend)
		if not url then
			vim.notify('gitlink: ' .. err, vim.log.levels.WARN)
			return
		end
		local lines = vim.api.nvim_buf_get_lines(0, lstart - 1, lend, false)
		vim.fn.setreg('+', format(url, vim.fn.expand('%:t'), lines))
	end
end

vim.keymap.set('x', '<leader>gs', yank_with_text(function(url, filename, lines)
	local indented = vim.tbl_map(function(l) return '\t' .. l end, lines)
	return table.concat({ url, 'code: ' .. filename, unpack(indented) }, '\n')
end), { desc = 'yank links and selected text in Scrapbox format' })

vim.keymap.set('x', '<leader>gm', yank_with_text(function(url, filename, lines)
	return table.concat({ url, '``` ' .. filename, table.concat(lines, '\n'), '```' }, '\n')
end), { desc = 'yank links and selected text in Markdown format' })
