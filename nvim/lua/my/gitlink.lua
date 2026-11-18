-- ファイルや行への GitHub パーマリンクを作る。
-- gitlinker.nvim はメンテされておらず、使っているのは GitHub の URL 生成だけなので自前で持つ
local M = {}

--- remote の URL をブラウザで開ける https の URL に変換する
--- scp 形式 (git@host:owner/repo.git)、ssh://、https:// を受け付ける
---@param remote string
---@return string?
M.remote_to_web = function(remote)
	remote = vim.trim(remote):gsub('%.git$', ''):gsub('/$', '')
	local host, path
	local rest = remote:match('^%w+://(.+)$')
	if rest then
		host, path = rest:gsub('^[^@/]+@', ''):match('^([^/:]+):?%d*/(.+)$')
	else
		host, path = remote:match('^[^@]+@([^:]+):(.+)$')
	end
	if not host then
		return nil
	end
	return ('https://%s/%s'):format(host, path)
end

--- blob の URL を組み立てる。lstart を省くと行を指さないファイルの URL になる
---@param base string remote_to_web() の結果
---@param rev string
---@param path string リポジトリルートからの相対パス
---@param lstart? integer
---@param lend? integer
---@return string
M.build_url = function(base, rev, path, lstart, lend)
	local url = ('%s/blob/%s/%s'):format(base, rev, path)
	if not lstart then
		return url
	end
	if lend and lend ~= lstart then
		return ('%s#L%d-L%d'):format(url, math.min(lstart, lend), math.max(lstart, lend))
	end
	return ('%s#L%d'):format(url, lstart)
end

---@param dir string
---@param args string[]
---@return string?
local function git(dir, args)
	local r = vim.system(vim.list_extend({ 'git', '-C', dir }, args), { text = true }):wait()
	if r.code ~= 0 then
		return nil
	end
	return vim.trim(r.stdout)
end

---@param dir string
---@return string?
local function web_base(dir)
	-- 追跡ブランチの remote を優先する。fork で upstream を追っていても、そちらの URL になるように
	local remote = git(dir, { 'rev-parse', '--abbrev-ref', '@{upstream}' })
	remote = remote and remote:match('^([^/]+)/') or 'origin'
	local url = git(dir, { 'remote', 'get-url', remote })
	return url and M.remote_to_web(url)
end

--- 現在のバッファの URL を返す
--- rev は HEAD のコミットにする。ブランチ名だと後で行がずれるため。push していないコミットだと 404 になるが、確認のために毎回 remote に問い合わせるほどではない
---@param lstart? integer
---@param lend? integer
---@return string? url, string? err
M.buf_url = function(lstart, lend)
	local name = vim.api.nvim_buf_get_name(0)
	-- ~/.config/nvim のように symlink 越しに開いていると toplevel と前方一致しないため実体のパスにする
	local file = name ~= '' and vim.uv.fs_realpath(name)
	if not file then
		return nil, 'buffer is not a file'
	end
	local dir = vim.fs.dirname(file)
	local root = git(dir, { 'rev-parse', '--show-toplevel' })
	local rev = root and git(dir, { 'rev-parse', 'HEAD' })
	local base = root and web_base(dir)
	if not (root and rev and base) then
		return nil, 'not in a git repository with a remote'
	end
	return M.build_url(base, rev, vim.fs.relpath(root, file), lstart, lend)
end

---@return string? url, string? err
M.repo_url = function()
	local base = web_base(vim.fn.getcwd())
	if not base then
		return nil, 'not in a git repository with a remote'
	end
	return base
end

return M
