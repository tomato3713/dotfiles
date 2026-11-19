local finder = require('my.finder')

local M = {}

--- quickfix 形式の item (vim.lsp.util.locations_to_items の戻り値) を finder の item にする
---@param qf vim.quickfix.entry
---@param group? integer
---@return finder.Item
local function to_item(qf, group)
	return {
		text = string.format('%s:%d: %s', finder.relpath(qf.filename), qf.lnum, vim.trim(qf.text or '')),
		file = qf.filename,
		lnum = qf.lnum,
		col = qf.col,
		group = group,
	}
end

--- 全クライアントに位置を問い合わせ、結果を quickfix 形式で返す
---@param method string
---@param extra? table position params に追加するパラメータ
---@param callback fun(items: vim.quickfix.entry[])
local function request_locations(method, extra, callback)
	local win = vim.api.nvim_get_current_win()
	vim.lsp.buf_request_all(0, method, function(client)
		return vim.tbl_extend('force', vim.lsp.util.make_position_params(win, client.offset_encoding), extra or {})
	end, function(results)
		local items = {}
		for client_id, res in pairs(results) do
			local client = vim.lsp.get_client_by_id(client_id)
			local result = res.result
			if client and result then
				-- 単一の Location が返ることもあるため配列に揃える
				if result.uri or result.targetUri then
					result = { result }
				end
				vim.list_extend(items, vim.lsp.util.locations_to_items(result, client.offset_encoding))
			end
		end
		callback(items)
	end)
end

--- 結果が 1 件ならそのまま移動し、複数ならファインダーで選ぶ
---@param method string
---@param title string
---@return fun()
function M.jump(method, title)
	return function()
		request_locations(method, nil, function(qf_items)
			if #qf_items == 0 then
				vim.notify('No locations found: ' .. title, vim.log.levels.INFO)
			elseif #qf_items == 1 then
				finder.open(to_item(qf_items[1]))
			else
				finder.start({ title = title, items = vim.tbl_map(to_item, qf_items) })
			end
		end)
	end
end

--- 定義と参照をまとめて表示する
function M.references()
	request_locations('textDocument/definition', nil, function(defs)
		request_locations('textDocument/references', { context = { includeDeclaration = false } }, function(refs)
			local items = {}
			for _, qf in ipairs(defs) do
				items[#items + 1] = to_item(qf, 1)
			end
			for _, qf in ipairs(refs) do
				items[#items + 1] = to_item(qf, 2)
			end
			finder.start({
				title = 'References',
				items = items,
				groups = { { title = 'Definition' }, { title = 'References' } },
			})
		end)
	end)
end

--- 呼び出し先 (outgoing) と呼び出し元 (incoming) をまとめて表示する
function M.call_hierarchy()
	local win = vim.api.nvim_get_current_win()
	vim.lsp.buf_request_all(0, 'textDocument/prepareCallHierarchy', function(client)
		return vim.lsp.util.make_position_params(win, client.offset_encoding)
	end, function(results)
		local client, item
		for client_id, res in pairs(results) do
			if res.result and res.result[1] then
				client, item = vim.lsp.get_client_by_id(client_id), res.result[1]
				break
			end
		end
		if not (client and item) then
			vim.notify('No call hierarchy item', vim.log.levels.INFO)
			return
		end

		local items, pending = {}, 2
		---@param group integer
		---@param uri string
		---@param range lsp.Range
		---@param name string
		local function add(group, uri, range, name)
			local qf = vim.lsp.util.locations_to_items({ { uri = uri, range = range } }, client.offset_encoding)[1]
			qf.text = name
			items[#items + 1] = to_item(qf, group)
		end
		local function finish()
			pending = pending - 1
			if pending == 0 then
				finder.start({
					title = 'Call Hierarchy: ' .. item.name,
					items = items,
					groups = { { title = 'Outgoing Calls' }, { title = 'Incoming Calls' } },
				})
			end
		end

		client:request('callHierarchy/outgoingCalls', { item = item }, function(_, calls)
			for _, call in ipairs(calls or {}) do
				add(1, call.to.uri, call.to.selectionRange, call.to.name)
			end
			finish()
		end)
		client:request('callHierarchy/incomingCalls', { item = item }, function(_, calls)
			for _, call in ipairs(calls or {}) do
				-- 呼び出し元の定義位置ではなく、実際に呼び出している箇所へ飛べるようにする
				add(2, call.from.uri, (call.fromRanges[1] or call.from.selectionRange), call.from.name)
			end
			finish()
		end)
	end)
end

function M.workspace_folders()
	local items = vim.tbl_map(function(dir)
		return { text = dir }
	end, vim.lsp.buf.list_workspace_folders())
	finder.start({
		title = 'Workspace Folders',
		items = items,
		preview = false,
		on_select = function(item)
			vim.cmd.tcd(item.text)
		end,
	})
end

return M
