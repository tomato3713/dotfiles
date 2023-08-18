require('aerial').setup({
	close_automatic_events = { "unsupported" }
})
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
