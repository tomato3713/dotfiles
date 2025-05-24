local helper = require("rc.helper.ddu.ui")

local init = function()
	require('my.utils').nvim_create_autocmd("FileType", {
		pattern = "ddu-ff",
		callback = function()
			vim.opt_local.cursorline = true
			local opts = { silent = true, buffer = true, noremap = true }
			-- open filter window
			vim.keymap.set("n", "i", helper.do_action("openFilterWindow"), opts)
			-- close ui
			vim.keymap.set("n", "<Esc>", helper.do_action("quit"), opts)
			vim.keymap.set("n", "q", helper.do_action("quit"), opts)

			vim.keymap.set("n", "<CR>", helper.item_action("default"), opts)
			vim.keymap.set("n", "<S-CR>", helper.item_action("open", { command = "split" }), opts)
			vim.keymap.set("n", "j", helper.move_ignore_dummy(1), opts)
			vim.keymap.set("n", "k", helper.move_ignore_dummy(-1), opts)
			vim.keymap.set("n", "a", helper.do_action("chooseAction"), opts)
			vim.keymap.set("n", "o", helper.do_action("expandItem", { mode = "toggle" }), opts)
			vim.keymap.set("n", "p", helper.do_action("togglePreview"), opts)
		end,
		desc = 'set keymap for ddu-ff',
	})
end

return {
	init = init,
	ui_params = {
		autoResize = true,
		prompt = '$ ',
		split = 'floating',
		autoAction = {
			name = 'preview',
		},
		maxDisplayItems = 500,
		startAutoAction = true,
		previewFloating = true,
		previewFloatingBorder = 'single',
		previewSplit = 'horizontal',
		floatingBorder = 'single',
		highlights = {
			floatingBorder = 'Special',
		},
	},
}
