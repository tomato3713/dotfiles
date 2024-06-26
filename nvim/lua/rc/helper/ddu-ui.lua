local _M = {}

--- https://zenn.dev/uga_rosa/articles/ace68bd6ba3480
---@param items table[] DduItem[]
---@param index number
---@return boolean
local function is_dummy(items, index)
	return items[index] and items[index].__sourceName == "dummy"
end

---@param dir number
---@return function
_M.move_ignore_dummy = function(dir)
	return function()
		local items = vim.fn["ddu#ui#get_items"]()
		local index = vim.fn.line(".") + dir

		while is_dummy(items, index) do
			index = index + dir
		end
		if 1 <= index and index <= #items then
			vim.cmd("normal! " .. index .. "gg")
		end
	end
end

---@param cmd string
---@param params? table
_M.do_action = function(cmd, params)
	params = params or vim.empty_dict()
	return function()
		vim.fn['ddu#ui#do_action'](cmd, params)
	end
end

---@param name string
---@param params? table
_M.item_action = function(name, params)
	return _M.do_action('itemAction', { name = name, params = params })
end

---@param cmd string
---@param is_stopinsert? boolean
_M.execute = function(cmd, is_stopinsert)
	return function()
		if is_stopinsert then
			vim.cmd.stopinsert()
		end
		vim.schedule(function()
			vim.fn["ddu#ui#ff#execute"](cmd)
		end)
	end
end

_M.get_item = function()
	return vim.fn["ddu#ui#get_item"]()
end


_M.isTree = function()
	local item = _M.get_item()
	return item.isTree == nil and false or item.isTree
end
return _M
