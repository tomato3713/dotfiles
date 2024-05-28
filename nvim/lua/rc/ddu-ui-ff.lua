local ui_helper = require("rc.helper.ddu-ui")

require('rc.utils').nvim_create_autocmd("FileType", {
	pattern = "ddu-ff",
	callback = function()
		vim.opt_local.cursorline = true
		local opts = { silent = true, buffer = true, noremap = true }
		-- open filter window
		vim.keymap.set("n", "i", ui_helper.do_action("openFilterWindow"), opts)
		-- close ui
		vim.keymap.set("n", "<Esc>", ui_helper.do_action("quit"), opts)
		vim.keymap.set("n", "q", ui_helper.do_action("quit"), opts)

		vim.keymap.set("n", "<CR>", ui_helper.item_action("default"), opts)
		vim.keymap.set("n", "<S-CR>", ui_helper.item_action("open", { command = "split" }, true), opts)
		vim.keymap.set("n", "j", ui_helper.move_ignore_dummy(1), opts)
		vim.keymap.set("n", "k", ui_helper.move_ignore_dummy(-1), opts)
		vim.keymap.set("n", "a", ui_helper.do_action("chooseAction"), opts)
		vim.keymap.set("n", "o", ui_helper.do_action("expandItem", { mode = "toggle" }), opts)
	end,
	desc = 'set keymap for ddu-ff',
})
