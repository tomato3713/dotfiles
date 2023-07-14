require "gitlinker".setup({
	mappings = nil,
})
-- yank the URL of the current or selected line.
vim.api.nvim_set_keymap('n', '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("n")<cr>', { silent = true })
vim.api.nvim_set_keymap('v', '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("v")<cr>', { silent = true })

-- repository home page url (copy and open browser).
vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>gB',
	'<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>',
	{ silent = true })

-- open browser in cursor line or selected lines.
vim.api.nvim_set_keymap('n', '<leader>gb',
	'<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
	{ silent = true })
vim.api.nvim_set_keymap('v', '<leader>gb',
	'<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
	{ silent = true })

-- yank  the URL of the current buffer file.
vim.api.nvim_set_keymap('n', '<leader>gf',
	'<cmd>lua require"gitlinker".get_buf_range_url({ add_current_line_on_normal_mode = false })<cr>',
	{ silent = true })

local yank_markdown = function()
	local pos1 = vim.fn.getpos("v")[2]
	local pos2 = vim.fn.getcurpos()[2]

	local lstart = math.min(pos1, pos2)
	local lend = math.max(pos1, pos2)

	-- yank selected text
	local text = vim.api.nvim_buf_get_lines(0, tonumber(lstart) - 1, tonumber(lend), false)

	local filename = vim.fn.expand('%:t')

	local yank_to_clipboard = function(text)
		return function(url)
			vim.fn.setreg('+', table.concat({ url, '``` ' .. filename, text, '```' }, '\n'))
		end
	end

	require('gitlinker').get_buf_range_url("v", { action_callback = yank_to_clipboard(table.concat(text, '\n')) })
end

local yank_scrapbox = function()
	local pos1 = vim.fn.getpos("v")[2]
	local pos2 = vim.fn.getcurpos()[2]

	local lstart = math.min(pos1, pos2)
	local lend = math.max(pos1, pos2)

	-- yank selected text
	local raw_text = vim.api.nvim_buf_get_lines(0, tonumber(lstart) - 1, tonumber(lend), false)
	local text = {}
	for k, v in pairs(raw_text) do
		text[k] = '\t' .. v
	end

	local filename = vim.fn.expand('%:t')

	local yank_to_clipboard = function(text)
		return function(url)
			vim.fn.setreg('+', table.concat({ url, 'code: ' .. filename, text }, '\n'))
		end
	end

	require('gitlinker').get_buf_range_url("v", { action_callback = yank_to_clipboard(table.concat(text, '\n')) })
end
vim.keymap.set('v', '<leader>gs', yank_scrapbox,
	{ silent = true, desc = 'yank links and selected text in Scrapbox format' })
vim.keymap.set('v', '<leader>gm', yank_markdown,
	{ silent = true, desc = 'yank links and selected text in Markdown format' })
