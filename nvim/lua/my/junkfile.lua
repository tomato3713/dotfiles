-- 使い捨てのメモを月ごとのディレクトリに作る
-- junkfile.vim と同じ <dir>/%Y/%m/<name> の配置にして、既存のメモをそのまま開けるようにしている

local M = {}

--- XDG_CACHE_HOME の指定があればそちらに従う
---@return string
function M.dir()
	local cache = vim.env.XDG_CACHE_HOME
	if cache == nil or cache == '' then
		cache = vim.fn.expand('~/.cache')
	end
	return cache .. '/junkfile'
end

---@param name string
---@param time? integer 省略時は現在時刻
---@return string
function M.path(name, time)
	return M.dir() .. os.date('/%Y/%m/', time) .. name
end

---@param name string
function M.open(name)
	local path = M.path(name)
	vim.fn.mkdir(vim.fs.dirname(path), 'p')
	vim.cmd.edit(vim.fn.fnameescape(path))
end

return M
