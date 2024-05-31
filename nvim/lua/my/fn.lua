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


return _M
