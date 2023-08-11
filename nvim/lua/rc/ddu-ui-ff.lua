---@param cmd string
---@param params? table
---@param is_stopinsert? boolean
local do_action = function(cmd, params, is_stopinsert)
	params = params or vim.empty_dict()
	return function()
		if is_stopinsert then vim.cmd('stopinsert') end
		vim.fn['ddu#ui#ff#do_action'](cmd, params)
	end
end

---@param cmd string
---@param is_stopinsert? boolean
local execute = function(cmd, is_stopinsert)
	return function()
		if is_stopinsert then vim.cmd('stopinsert') end
		vim.fn['ddu#ui#ff#execute'](cmd)
	end
end

--- https://zenn.dev/uga_rosa/articles/ace68bd6ba3480
---@param items table[] DduItem[]
---@param index number
---@return boolean
local function is_dummy(items, index)
	return items[index] and items[index].__sourceName == "dummy"
end

---@param dir number
---@return function
local function move_ignore_dummy(dir)
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = 'ddu-ff-filter',
	callback = function()
		local opts = { silent = true, buffer = true, noremap = true }
		-- close filter window
		vim.keymap.set('n', '<Esc>', do_action("closeFilterWindow"), opts)
		-- close ui
		vim.keymap.set('i', '<C-c>', do_action("quit", nil, true), opts)

		vim.keymap.set('i', '<CR>', do_action("itemAction", nil, true), opts)
		vim.keymap.set('i', '<C-n>', execute('normal j'), opts)
		vim.keymap.set('i', '<C-p>', execute('normal k'), opts)
		vim.keymap.set('i', '<C-t>', do_action("preview"), opts)
		vim.keymap.set('i', '<C-e>', do_action("expandItem", { mode = "toggle" }), opts)
	end
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = 'ddu-ff',
	callback = function()
		local opts = { silent = true, buffer = true, noremap = true }
		-- open filter window
		vim.keymap.set('n', 'i', do_action('openFilterWindow'), opts)
		-- close ui
		vim.keymap.set('n', '<Esc>', do_action('quit'), opts)

		vim.keymap.set('n', '<CR>', do_action('itemAction'), opts)
		vim.keymap.set('n', 'j', move_ignore_dummy(1), opts)
		vim.keymap.set('n', 'k', move_ignore_dummy(-1), opts)
	end
})
