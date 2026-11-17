local _M = {}

--- Setup user commands
_M.setup = function()
	local opt = { range = true }

	local fn = require('my.fn')

	vim.api.nvim_create_user_command('CommaPeriod', fn.replace_comma_period_to_kutoten_in_selected_range, opt)
	vim.api.nvim_create_user_command('Kutoten', fn.replace_kutoten_to_comma_period_in_selected_range, opt)

	vim.api.nvim_create_user_command('CountChars', fn.count_characters_in_selected_range, opt)

	local junkfile = require('my.junkfile')
	vim.api.nvim_create_user_command('JunkfileDiary', function()
		junkfile.open(os.date('%Y-%m-%d.md'))
	end, {})
	vim.api.nvim_create_user_command('JunkNote', function()
		junkfile.open('main.md')
	end, {})
end
return _M
