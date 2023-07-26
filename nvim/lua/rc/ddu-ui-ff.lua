vim.api.nvim_create_autocmd("FileType", {
	pattern = 'ddu-ff-filter',
	callback = function()
		local opts = { silent = true, buffer = true }
		vim.keymap.set('i', '<CR>', '<Esc><Cmd>call ddu#ui#ff#do_action("itemAction")<CR>', opts)
		vim.keymap.set('i', '<Esc>', '<Esc><Cmd>call ddu#ui#ff#do_action("quit")<CR>', opts)
		vim.keymap.set('i', '<C-n>', '<C-o><Cmd>call ddu#ui#ff#execute(\'normal j\')<CR>', opts)
		vim.keymap.set('i', '<C-p>', '<C-o><Cmd>call ddu#ui#ff#execute(\'normal k\')<CR>', opts)
		vim.keymap.set('i', '<C-t>', '<C-o><Cmd>call ddu#ui#ff#do_action("preview")<CR>', opts)
		vim.keymap.set('i', '<C-e>',
			'<C-o><Cmd>call ddu#ui#ff#do_action("expandItem", { "mode":    "toggle" })<CR>', opts)
	end
})
