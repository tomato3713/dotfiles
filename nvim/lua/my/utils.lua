local M = {}

--- try catch
---@param what table
---@return unknown
M.try_catch = function(what)
	local status, result = pcall(what.try)
	if not status then
		if what.catch ~= nil then
			what.catch(result)
		end
	end
	if what.finally ~= nil then
		what.finally(result)
	end
	return result
end

--- keep cursor
---@param cmd function
---@return nil
M.keep_cursor = function(cmd)
	return function()
		local curwin_id = vim.fn.win_getid()
		local view = vim.fn.winsaveview()

		M.try_catch({
			try = cmd,
			finally = function()
				if vim.fn.win_getid() == curwin_id then
					vim.fn.winrestview(view)
				end
			end,
		})
	end
end

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
