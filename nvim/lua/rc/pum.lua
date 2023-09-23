local res = {
	{
		key = '<C-n>',
		func = function() vim.fn['pum#map#insert_relative'](1, 'loop') end,
		desc = 'cursor down and loop items'
	},
	{
		key = '<C-p>',
		func = function() vim.fn['pum#map#insert_relative'](-1, 'loop') end,
		desc = 'cursor up and loop items'
	},
	{
		key = '<C-y>',
		func = function() vim.fn['pum#map#confirm']() end,
		desc = 'confirm the item'
	},
	{
		key = '<C-e>',
		func = function() vim.fn['pum#map#cancel']() end,
		desc = 'cancel items'
	},
	{
		key = '<C-u>',
		func = function() vim.fn['pum#map#insert_relative_page'](1, 'loop') end,
		desc = 'go to next page'
	},
	{
		key = '<C-d>',
		func = function() vim.fn['pum#map#insert_relative_page'](-1, 'loop') end,
		desc = 'go back page'
	},
	{
		key = '<Tab>',
		func = function()
			if vim.fn['ddc#visible']() then
				vim.fn['pum#map#insert_relative'](1, 'loop')
			else
				return '\t'
			end
		end,
		desc = ''
	},
	{
		key = '<S-Tab>',
		func = function() vim.fn['pum#map#insert_relative'](-1, 'loop') end,
		desc = ''
	}
}

for _, v in ipairs(res) do
	vim.keymap.set({ 'i', 'c' }, v.key, v.func, { silent = true, desc = v.desc, expr = true, noremap = true })
end

vim.fn['pum#set_option']({
	max_width = 100,
	border = 'single',
})
