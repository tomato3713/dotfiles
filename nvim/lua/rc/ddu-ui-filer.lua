local ui_helper = require('rc.helper.ddu-ui')

require('rc.utils').nvim_create_autocmd("FileType", {
	pattern = 'ddu-filer',
	callback = function()
		local opts = { silent = true, buffer = true }
		-- close ui
		vim.keymap.set('n', '<Esc>', ui_helper.do_action('quit'), opts)
		vim.keymap.set('n', 'q', ui_helper.do_action('quit'), opts)

		vim.keymap.set('n', 'e', ui_helper.do_action("expandItem", { mode = "toggle" }), opts)
		vim.keymap.set('n', 'l', ui_helper.do_action("expandItem", { mode = "toggle" }), opts)
		vim.keymap.set('n', 'h', ui_helper.do_action("expandItem", { mode = "toggle" }), opts)

		vim.keymap.set('n', 'j', ui_helper.move_ignore_dummy(1), opts)
		vim.keymap.set('n', 'k', ui_helper.move_ignore_dummy(-1), opts)


		vim.keymap.set('n', '<CR>', function()
			if ui_helper.isTree() then
				ui_helper.item_action('narrow')()
			else
				ui_helper.item_action('open', { command = 'vsplit' })()
			end
		end, opts)

		vim.keymap.set('n', '<Space>', function()
			if ui_helper.isTree() then
				ui_helper.item_action('narrow')()
			else
				ui_helper.item_action('open', { command = 'split' })()
			end
		end, opts)

		vim.keymap.set('n', '..',
			ui_helper.item_action('narrow', { path = '..' }),
			opts)
	end,
	desc = 'set keymap ddu-filer',
})
