local _M = {}

--- Setup user commands
_M.setup = function()
	local opt = { range = true }

	local fn = require('my.fn')

	vim.api.nvim_create_user_command('CommaPeriod', fn.replace_comma_period_to_kutoten_in_selected_range, opt)
	vim.api.nvim_create_user_command('Kutoten', fn.replace_kutoten_to_comma_period_in_selected_range, opt)

	vim.api.nvim_create_user_command('CountChars', fn.count_characters_in_selected_range, opt)

	local junkfile = require('my.junkfile')
	-- カレンダーでの呼び名 (Daily / Monthly) とコマンド名を揃え、どのメモを開くのか名前で分かるようにする
	vim.api.nvim_create_user_command('JunkDaily', function()
		junkfile.open(os.date('%Y-%m-%d.md'))
	end, {})
	vim.api.nvim_create_user_command('JunkMonthly', function()
		junkfile.open('main.md')
	end, {})
	-- 月で分けず、話題ごとに 1 つのファイルへ書き足していくメモ
	vim.api.nvim_create_user_command('JunkNote', function(args)
		junkfile.open_topic(args.args)
	end, {
		nargs = 1,
		complete = function(lead)
			return vim.tbl_filter(function(topic)
				return vim.startswith(topic, lead)
			end, junkfile.topics())
		end,
	})
	vim.api.nvim_create_user_command('JunkCalendar', function()
		require('my.junkcalendar').open()
	end, {})
end
return _M
