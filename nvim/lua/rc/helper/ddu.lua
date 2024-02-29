local M = {}

--- patch_local()
---@param name string
---@param config table
function M.patch_local(name, config)
	vim.fn['ddu#custom#patch_local'](name, config)
end

--- patch_global
function M.patch_global(...)
	vim.fn['ddu#custom#patch_global'](...)
end

--- https://zenn.dev/uga_rosa/articles/ace68bd6ba3480
---@class Source
---@field name string
---@field params? table

---@param word string
---@param color string
---@return Source
function M.separator(word, color)
	local hlGroup = 'DduDummy' .. color:gsub('[^a-zA-Z0-9]', '')
	vim.api.nvim_set_hl(0, hlGroup, { fg = color })
	return {
		name = 'dummy',
		params = { word = word, hlGroup = hlGroup },
	}
end

function M.start(config)
	return function() vim.fn['ddu#start'](config) end
end

return M
