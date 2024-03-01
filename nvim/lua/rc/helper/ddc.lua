local M = {}

-- https://github.com/uga-rosa/dotfiles/blob/92a4de22aa1722d3285b6ffd39c50cbf3925272c/nvim/lua/rc/helper/ddc.lua#L19
function M.patch_buffer(...)
	vim.fn["ddc#custom#patch_buffer"](...)
end

function M.patch_global(...)
	vim.fn["ddc#custom#patch_global"](...)
end

---@param ... string
function M.remove_buffer(...)
	local options = vim.fn["ddc#custom#get_buffer"]()
	local root = options
	local keys = { ... }
	local last_key = table.remove(keys)
	for _, key in ipairs(keys) do
		options = options[key]
	end
	options[last_key] = nil
	if vim.tbl_isempty(root) then
		root = vim.empty_dict()
	end
	vim.fn["ddc#custom#set_buffer"](root)
end

function M.enable()
	vim.fn['ddc#enable']()
end

function M.enable_cmdline_completion()
	vim.fn['ddc#enable_cmdline_completion']()
end

function M.enable_terminal_completion()
	vim.fn['ddc#enable_terminal_completion']()
end

return M
