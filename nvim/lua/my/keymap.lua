local _M = {}

_M.global_mapping = function()
	-- vim.keymap.set('n', '<C-n>', ':bnext<CR>')
	-- vim.keymap.set('n', '<C-p>', ':bnext<CR>')

	vim.keymap.set('n', '<C-w>t', ':split | terminal<CR>')
	vim.keymap.set('n', "gf", require('my.fn').open_browser_or_buffer_under_cursor)
end

_M.filetype_mapping = function()
	--- close by 'q'
	require('my.utils').nvim_create_autocmd({ 'FileType' }, {
		pattern = { 'help', 'lspinfo', 'qf' },
		callback = function()
			vim.keymap.set('n', 'q', function()
				vim.api.nvim_win_close(0, true)
			end, { buffer = true, noremap = true })
		end,
		desc = 'close window with "q"',
	})
end

return _M
