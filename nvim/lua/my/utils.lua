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

-- @params list list
-- @return bool
M.contains = function(list, element)
	for _, v in pairs(list) do
		if v == element then
			return true
		end
	end
	return false
end

-- @params obj object
-- @params indent number
-- @return string
local function dumper(o, indent)
	if type(o) == "table" then
		local s = "{\n"
		for k, v in pairs(o) do
			s = s .. string.rep(" ", indent) .. "'" .. k .. "' = " .. dumper(v, indent + 1) .. ",\n"
		end
		return s .. string.rep(" ", indent) .. "}"
	else
		return tostring(o)
	end
end

-- @params obj object
-- @return string
M.dump = function(o)
	return dumper(o, 0)
end

M.my_group = vim.api.nvim_create_augroup('vimrcEx', {})

--- create autocmd in vimrcEx group
---@param event any
---@param opts? table<string, any>
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

return M
