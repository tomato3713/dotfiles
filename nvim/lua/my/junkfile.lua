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

---@param path string
local function edit(path)
	vim.fn.mkdir(vim.fs.dirname(path), 'p')
	vim.cmd.edit(vim.fn.fnameescape(path))
end

---@param name string
function M.open(name)
	edit(M.path(name))
end

-- 話題ごとのメモは知見を蓄積するためのものなので、月で分けずに 1 ファイルへ書き足していく
---@return string
function M.topic_dir()
	return M.dir() .. '/topics'
end

---@param topic string
---@return string
function M.topic_path(topic)
	return M.topic_dir() .. '/' .. topic .. '.md'
end

--- 既存の話題名を返す (補完用)
---@return string[]
function M.topics()
	local topics = {}
	for name, type in vim.fs.dir(M.topic_dir()) do
		if type == 'file' and name:match('%.md$') then
			topics[#topics + 1] = name:gsub('%.md$', '')
		end
	end
	table.sort(topics)
	return topics
end

---@param topic string
function M.open_topic(topic)
	-- '../' などで topics ディレクトリの外にファイルを作れないようにする
	if topic:find('/', 1, true) or topic == '.' or topic == '..' then
		vim.notify('JunkNote: 話題名に / は使えません: ' .. topic, vim.log.levels.ERROR)
		return
	end
	edit(M.topic_path(topic))
end

return M
