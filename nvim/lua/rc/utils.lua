local M = {}

M.try_catch = function(what)
	local status, result = pcall(what.try)
	if not status then
		if what.catch ~= nil then what.catch(result) end
	end
	if what.finally ~= nil then what.finally(result) end
	return result
end

-- @return function
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
			end
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

return M
