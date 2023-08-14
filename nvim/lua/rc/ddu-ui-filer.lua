local ui_helper = require('rc.ddu-ui')

vim.api.nvim_create_autocmd("FileType", {
	pattern = 'ddu-filer',
	callback = function()
		local opts = { silent = true, buffer = true }
		-- close ui
		vim.keymap.set('n', '<Esc>', ui_helper.do_action('quit'), opts)

		vim.keymap.set('n', 'e', ui_helper.do_action("expandItem", { mode = "toggle" }), opts)

		vim.keymap.set('n', '<CR>', ui_helper.item_action('default'), opts)
		vim.keymap.set('n', 'j', ui_helper.move_ignore_dummy(1), opts)
		vim.keymap.set('n', 'k', ui_helper.move_ignore_dummy(-1), opts)
	end
})