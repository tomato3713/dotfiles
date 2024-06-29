require('my.utils').nvim_create_autocmd({ 'FileType' }, {
	pattern = 'gin-status',
	callback = function()
		local keymap = vim.keymap.set
		local opts = { buffer = true, noremap = true }
		keymap({ 'n' }, 'h', '<Plug>(gin-action-stage)', opts)
		keymap({ 'n' }, 'l', '<Plug>(gin-action-unstage)', opts)
	end,
})

local opt = { noremap = true, nowait = true }

vim.keymap.set("n", "<C-g>s", "<Cmd>GinStatus<CR>", opt)
vim.keymap.set("n", "<C-g>l", "<Cmd>GinLog<CR>", opt)
vim.keymap.set("n", "<C-g>b", "<Cmd>GinBranch<CR>", opt)
vim.keymap.set("n", "<C-g>d", "<Cmd>GinDiff<CR>", opt)
vim.keymap.set("n", "<C-g>D", "<Cmd>GinDiff --staged<CR>", opt)
vim.keymap.set("n", "<C-g>c", "<Cmd>Gin commit<CR>", opt)
