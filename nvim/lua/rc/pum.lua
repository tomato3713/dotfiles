local res = {
	{
		mode = { 'i', 'c' },
		key = '<C-n>',
		func = function() vim.fn['pum#map#insert_relative'](1, 'loop') end,
		opts = {
			desc = 'cursor down and loop items',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<C-p>',
		func = function() vim.fn['pum#map#insert_relative'](-1, 'loop') end,
		opts = {
			desc = 'cursor up and loop items',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<C-y>',
		func = function()
			local info = vim.fn["pum#complete_info"]()
			if info.pum_visible then
				vim.fn['pum#map#confirm']()
			end
		end,
		opts = {
			desc             = 'confirm the item',
			silent           = true,
			expr             = true,
			replace_keycodes = false,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<C-e>',
		func = function() vim.fn['pum#map#cancel']() end,
		opts = {
			desc = 'cancel items',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<C-u>',
		func = function() vim.fn['pum#map#insert_relative_page'](1, 'loop') end,
		opts = {
			desc = 'go to next page',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<C-d>',
		func = function() vim.fn['pum#map#insert_relative_page'](-1, 'loop') end,
		opts = {
			desc = 'go back page',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<Tab>',
		func = function()
			if vim.fn['pum#visible']() then
				vim.fn['pum#map#insert_relative'](1, 'loop')
			else
				return '<Tab>'
			end
		end,
		opts = {
			desc = 'cursor down and loop items',
			noremap = true,
		}
	},
	{
		mode = { 'i', 'c' },
		key = '<S-Tab>',
		func = function()
			if vim.fn['pum#visible']() then
				vim.fn['pum#map#insert_relative'](-1, 'loop')
			else
				return '<S-Tab>'
			end
		end,
		opts = {
			desc = 'cursor up and loop items',
			noremap = true,
		}
	}
}

for _, v in ipairs(res) do
	vim.keymap.set(v.mode, v.key, v.func, v.opts)
end

vim.fn['pum#set_option']({
	item_orders = { 'kind', 'space', 'abbr', 'space', 'menu' },
	max_width = 100,
	border = 'rounded',
})
