require('mini.comment').setup {
	options = {
		custom_commentstring = function()
			return require('ts_context_commentstring.internal').calculate_commentstring() or
			    vim.bo.commentstring
		end,
	},
	mappings = {
		comment = 'gc', -- Toggle comment (like `gcip` comment inner paragraph)
		comment_line = 'gcc',
		textobject = 'gc',
	},
}

require('mini.splitjoin').setup {
	mappings = {
		toggle = 'gs',
		split = '',
		join = '',
	},
	detect = {
		brackets = { '%b()', '%b[]', '%b{}', '%b<>' },
		separator = ',',
		exclude_regions = { '%b()', '%b[]', '%b{}', '%b""', "%b''" }
	}
}

local pick = require('mini.pick')
pick.setup()
vim.ui.select = pick.ui_select
