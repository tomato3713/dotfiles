local _M = {}

-- toggle "，/．" and "、/。"
_M.replace_comma_period_to_kutoten_in_selected_range = function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/、/，/ge')
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/。/．/ge')
	vim.fn.setpos('.', cursor)
end

-- toggle "、/。" and "，/．"
_M.replace_kutoten_to_comma_period_in_selected_range = function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/，/、/ge')
	vim.api.nvim_command('silent keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/．/。/ge')
	vim.fn.setpos('.', cursor)
end

_M.count_characters_in_selected_range = function(opts)
	local cursor = vim.fn.getcurpos()
	vim.api.nvim_command('keepjumps keeppatterns' .. opts.line1 .. ',' .. opts.line2 .. 's/./&/gn')
	vim.fn.setpos('.', cursor)
end

-- set default filtype as plain text
_M.none_ft_set_txt = function()
	if string.len(vim.o.filetype) == 0 then
		vim.o.filetype = 'txt'
	end
end

--- Open the URL under the cursor in the browser.
--- ref: https://blog.atusy.net/2023/12/09/gf-open-url/
_M.open_browser_or_buffer_under_cursor = function()
	local cfile = vim.fn.expand("<cfile>")
	if cfile:match("^https?://") then
		vim.ui.open(cfile)
	else
		vim.cmd("normal! gF")
	end
end


return _M
