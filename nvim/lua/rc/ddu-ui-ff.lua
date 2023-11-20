local ui_helper = require("rc.ddu-ui")

---@param cmd string
---@param is_stopinsert? boolean
local execute = function(cmd, is_stopinsert)
	return function()
		if is_stopinsert then
			vim.cmd.stopinsert()
		end
		vim.schedule(function()
			vim.fn["ddu#ui#ff#execute"](cmd)
		end)
	end
end

require('rc.utils').nvim_create_autocmd("FileType", {
	pattern = "ddu-ff-filter",
	callback = function()
		vim.opt_local.cursorline = false
		local opts = { silent = true, buffer = true, noremap = true }
		-- close filter window
		vim.keymap.set("i", "<Esc>", ui_helper.do_action("closeFilterWindow", nil, true), opts)
		-- close ui
		vim.keymap.set("i", "<C-c>", ui_helper.do_action("quit", nil, true), opts)

		vim.keymap.set("i", "<CR>", ui_helper.item_action("default", nil, true), opts)
		vim.keymap.set("i", "<S-CR>", ui_helper.item_action("open", { command = "split" }, true), opts)
		vim.keymap.set("i", "<C-n>", execute("normal j"), opts)
		vim.keymap.set("i", "<C-p>", execute("normal k"), opts)
		vim.keymap.set("i", "<C-t>", ui_helper.do_action("preview"), opts)
		vim.keymap.set("i", "<C-e>", ui_helper.do_action("expandItem", { mode = "toggle" }), opts)
		vim.keymap.set("i", "<C-a>", ui_helper.do_action("chooseAction"), opts)
	end,
	desc = 'set keymap for ddu-ff-filter',
})

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
	end,
	desc = 'set keymap for ddu-ff',
})
