local _M = {}

--- Setup user commands
_M.setup = function()
	local opt = { range = true }

	local fn = require('my.fn')

	vim.api.nvim_create_user_command('CommaPeriod', fn.replace_comma_period_to_kutoten_in_selected_range, opt)
	vim.api.nvim_create_user_command('Kutoten', fn.replace_kutoten_to_comma_period_in_selected_range, opt)

	vim.api.nvim_create_user_command('CountChars', fn.count_characters_in_selected_range, opt)
end
return _M
