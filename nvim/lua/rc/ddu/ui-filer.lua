local helper = require('rc.helper.ddu.ui')

local init = function()
	require('my.utils').nvim_create_autocmd("FileType", {
		pattern = 'ddu-filer',
		callback = function()
			local opts = { silent = true, buffer = true }
			-- close ui
			vim.keymap.set('n', '<Esc>', helper.do_action('quit'), opts)
			vim.keymap.set('n', 'q', helper.do_action('quit'), opts)
			vim.keymap.set("n", "a", helper.do_action("chooseAction"), opts)

			vim.keymap.set('n', 'e', helper.do_action("expandItem", { mode = "toggle" }), opts)
			vim.keymap.set('n', 'l', helper.do_action("expandItem", { mode = "toggle" }), opts)
			vim.keymap.set('n', 'h', helper.do_action("expandItem", { mode = "toggle" }), opts)

			vim.keymap.set('n', 'j', helper.move_ignore_dummy(1), opts)
			vim.keymap.set('n', 'k', helper.move_ignore_dummy(-1), opts)

			vim.keymap.set('n', 'p', helper.do_action("togglePreview"), opts)

			vim.keymap.set('n', '<CR>', function()
				if helper.isTree() then
					helper.item_action('narrow')()
				else
					helper.item_action('default')()
				end
			end, opts)

			vim.keymap.set('n', '<Space>', function()
				if helper.isTree() then
					helper.item_action('narrow')()
				else
					helper.item_action('default')()
				end
			end, opts)

			vim.keymap.set('n', '..',
				helper.item_action('narrow', { path = '..' }),
				opts)
		end,
		desc = 'set keymap ddu-filer',
	})
end

return {
	init = init,
	ui_params = {
		statusline = false,
		displayRoot = true,
		displayTree = true,
		split = 'floating',
		floatingBorder = 'single',
		startAutoAction = true,
		previewFloating = true,
		autoAction = {
			name = 'preview',
		},
	}
}
