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
