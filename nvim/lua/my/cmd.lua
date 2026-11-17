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
	-- 引数なしは今月の main.md、引数ありは話題ごとに書き足していくメモを開く
	vim.api.nvim_create_user_command('JunkNote', function(args)
		if args.args == '' then
			junkfile.open('main.md')
		else
			junkfile.open_topic(args.args)
		end
	end, {
		nargs = '?',
		complete = function(lead)
			return vim.tbl_filter(function(topic)
				return vim.startswith(topic, lead)
			end, junkfile.topics())
		end,
	})
end
return _M
