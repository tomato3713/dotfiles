local eq = MiniTest.expect.equality
local gitlink = require('my.gitlink')

local T = MiniTest.new_set()

T['remote_to_web'] = MiniTest.new_set({
	parametrize = {
		{ 'git@github.com:owner/repo.git' },
		{ 'https://github.com/owner/repo.git' },
		{ 'https://github.com/owner/repo' },
		{ 'ssh://git@github.com/owner/repo.git' },
		{ 'ssh://git@github.com:22/owner/repo.git' },
	},
})

T['remote_to_web']['どの形式の remote も https の URL にする'] = function(remote)
	eq(gitlink.remote_to_web(remote), 'https://github.com/owner/repo')
end

T['remote_to_web']['URL として解釈できない remote は nil を返す'] = function()
	eq(gitlink.remote_to_web('/path/to/local/repo'), nil)
end

T['build_url'] = MiniTest.new_set()

local base = 'https://github.com/owner/repo'

T['build_url']['行を指定しなければファイルの URL になる'] = function()
	eq(gitlink.build_url(base, 'abc', 'a/b.lua'), base .. '/blob/abc/a/b.lua')
end

T['build_url']['1 行だけなら範囲にしない'] = function()
	eq(gitlink.build_url(base, 'abc', 'a.lua', 3, 3), base .. '/blob/abc/a.lua#L3')
end

T['build_url']['逆順に渡された範囲も小さい行から並べる'] = function()
	eq(gitlink.build_url(base, 'abc', 'a.lua', 9, 2), base .. '/blob/abc/a.lua#L2-L9')
end

T['buf_url'] = MiniTest.new_set()

T['buf_url']['このリポジトリのファイルは HEAD のコミットを指す URL になる'] = function()
	vim.cmd.edit('lua/my/gitlink.lua')
	local head = vim.trim(vim.fn.system({ 'git', 'rev-parse', 'HEAD' }))
	local url = gitlink.buf_url(1, 2)
	eq(url:match('/blob/(%x+)/nvim/lua/my/gitlink%.lua#L1%-L2$'), head)
	vim.cmd.bwipeout()
end

T['buf_url']['ファイルでないバッファはエラーを返す'] = function()
	vim.cmd.enew()
	local url, err = gitlink.buf_url()
	eq({ url, err }, { nil, 'buffer is not a file' })
end

return T
