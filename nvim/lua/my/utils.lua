local M = {}

M.my_group = vim.api.nvim_create_augroup('vimrcEx', {})

--- create autocmd in vimrcEx group
---@param event any
-- ---@param opts? vim.api.keyset.create_autocmd_opts
-- @return number
M.nvim_create_autocmd = function(event, opts)
	opts.group = M.my_group
	vim.api.nvim_create_autocmd(event, opts)
end

M.clear_vimrc_autocmd = function()
	vim.api.nvim_clear_autocmds({
		group = M.my_group,
	})
end

--- url のファイルを path にダウンロードする。is_override が false なら既存のファイルは残す
---@param url string
---@param path string
---@param is_override boolean
M.download_file = function(url, path, is_override)
	path = vim.fn.expand(path)
	if vim.uv.fs_stat(path) and not is_override then
		return
	end
	vim.fn.mkdir(vim.fs.dirname(path), 'p')
	-- os.execute はシェル経由で path をクォートしないため、引数を配列で渡す vim.system を使う
	vim.system({ 'curl', '-fsSL', '-o', path, url }):wait()
end

return M
