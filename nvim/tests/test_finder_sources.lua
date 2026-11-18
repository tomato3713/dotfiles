local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				_G.sources = require('my.finder.sources')
				-- finder.start を差し替え、ソースが渡した opts を検査できるようにする
				local finder = require('my.finder')
				local start = finder.start
				finder.start = function(opts)
					_G.opts = opts
					_G.f = start(opts)
					return _G.f
				end
			]])
		end,
		post_once = child.stop,
	},
})

--- 一時ディレクトリにファイルを作ってそこへ移動する
---@param files table<string, string[]>
local function chdir_to_fixture(files)
	child.lua([[
		local dir = vim.fn.tempname()
		vim.fn.mkdir(dir, 'p')
		for path, lines in pairs(...) do
			local full = dir .. '/' .. path
			vim.fn.mkdir(vim.fs.dirname(full), 'p')
			vim.fn.writefile(lines, full)
		end
		vim.cmd.cd(dir)
	]], { files })
end

local function wait_loaded()
	child.lua([[vim.wait(3000, function() return _G.f and not _G.f.loading end)]])
end

local function item_texts()
	local texts = child.lua_get([[vim.tbl_map(function(i) return i.text end, _G.f.items)]])
	table.sort(texts)
	return texts
end

local function skip_without_rg()
	if vim.fn.executable('rg') == 0 then
		MiniTest.skip('rg がインストールされていない')
	end
end

T['files'] = MiniTest.new_set()

T['files']['依存ディレクトリ配下のファイルを候補から除外する'] = function()
	skip_without_rg()
	chdir_to_fixture({
		['a.lua'] = { '' },
		['.hidden'] = { '' },
		['node_modules/x.js'] = { '' },
		['vendor/y.pl'] = { '' },
	})
	child.lua([[sources.files()]])
	wait_loaded()
	eq(item_texts(), { '.hidden', 'a.lua' })
end

T['grep'] = MiniTest.new_set()

T['grep']['rg の出力からファイル・行・列を取り出す'] = function()
	skip_without_rg()
	chdir_to_fixture({ ['a.txt'] = { 'foo', '  bar baz' } })
	child.lua([[sources.grep('baz')]])
	wait_loaded()
	eq(child.lua_get([[_G.f.items]]), {
		{ text = 'a.txt:2: bar baz', filter_text = 'a.txt', file = child.fn.getcwd() .. '/a.txt', lnum = 2, col = 7 },
	})
end

T['grep']['検索対象のディレクトリを検索パターンの欄のタイトルに表示する'] = function()
	chdir_to_fixture({})
	child.lua([[sources.grep('')]])
	eq(child.lua_get([[vim.api.nvim_win_get_config(_G.f.input_wins[1]).title[1][1] ]]),
		' Grep: ' .. child.fn.fnamemodify(child.fn.getcwd(), ':~') .. ' ')
end

T['grep']['起動後にカレントディレクトリが変わっても起動時のディレクトリで検索して開く'] = function()
	skip_without_rg()
	chdir_to_fixture({ ['a.txt'] = { 'foo' } })
	local dir = child.fn.getcwd()
	child.lua([[sources.grep('')]])
	child.cmd('cd /')
	child.type_keys('foo')
	child.lua([[vim.wait(3000, function() return #_G.f.items > 0 and not _G.f.loading end)]])
	child.type_keys('<C-g>', '<CR>')
	child.lua([[vim.wait(200, function() return vim.api.nvim_buf_get_name(0) ~= '' end)]])
	eq(child.fn.resolve(child.api.nvim_buf_get_name(0)), child.fn.resolve(dir .. '/a.txt'))
end

T['grep']['検索パターンの欄を書き換えると rg を実行し直す'] = function()
	skip_without_rg()
	chdir_to_fixture({ ['a.txt'] = { 'foo' }, ['b.txt'] = { 'bar' } })
	child.lua([[sources.grep('foo')]])
	wait_loaded()
	eq(item_texts(), { 'a.txt:1: foo' })
	-- 単語を渡したときは絞り込み欄から始まるので、検索パターンの欄へ移って書き換える
	child.type_keys('<C-g>', '<C-u>', 'bar')
	child.lua([[vim.wait(3000, function() return _G.f.items[1] and _G.f.items[1].file == 'b.txt' and not _G.f.loading end)]])
	eq(item_texts(), { 'b.txt:1: bar' })
end

T['grep']['絞り込み欄は中身ではなくファイルパスだけを対象にする'] = function()
	skip_without_rg()
	-- 中身に xyz を含む行と、パスに xyz を含むファイル
	chdir_to_fixture({ ['a.txt'] = { 'hit xyz' }, ['xyz.txt'] = { 'hit' } })
	child.lua([[sources.grep('hit')]])
	wait_loaded()
	child.type_keys('xyz')
	child.lua([[vim.wait(50)]])
	eq(child.lua_get([[vim.tbl_map(function(r) return r.item.filter_text end, _G.f.results)]]), { 'xyz.txt' })
end

T['grep']['検索パターンが空なら検索パターンの欄から入力を始める'] = function()
	child.lua([[sources.grep('')]])
	eq(child.api.nvim_get_current_win(), child.lua_get([[_G.f.input_wins[1] ]]))
	eq(child.lua_get([[#_G.f.items]]), 0)
end

T['buffers'] = MiniTest.new_set()

T['buffers']['今いるバッファを末尾に並べる'] = function()
	child.lua([[
		vim.cmd.edit('first')
		vim.cmd.edit('second')
		sources.buffers()
	]])
	eq(child.lua_get([[vim.tbl_map(function(i) return i.text end, _G.opts.items)]]), { 'first', 'second' })
end

T['tabs'] = MiniTest.new_set()

T['tabs']['選んだタブに移動する'] = function()
	child.lua([[
		vim.cmd.tabnew()
		vim.cmd.tabnew()
		sources.tabs()
	]])
	child.type_keys('<CR>')
	child.lua([[vim.wait(200, function() return vim.fn.tabpagenr() == 1 end)]])
	eq(child.fn.tabpagenr(), 1)
end

T['diagnostics'] = MiniTest.new_set()

T['diagnostics']['重大度の高い順に並べてアイコンで重大度を示す'] = function()
	child.lua([[
		local ns = vim.api.nvim_create_namespace('test')
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'a', 'b' })
		vim.diagnostic.set(ns, 0, {
			{ lnum = 0, col = 0, message = 'warn', severity = vim.diagnostic.severity.WARN },
			{ lnum = 1, col = 0, message = 'err', severity = vim.diagnostic.severity.ERROR },
		})
		sources.diagnostics()
	]])
	eq(child.lua_get([[vim.tbl_map(function(i) return { i.icon, i.lnum } end, _G.opts.items)]]), {
		{ 'E', 2 },
		{ 'W', 1 },
	})
end

T['marks'] = MiniTest.new_set()

T['marks']['英字のマークだけを候補にする'] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one', 'two' })
		vim.api.nvim_buf_set_mark(0, 'a', 2, 0, {})
		vim.cmd('normal! m"')
		sources.marks()
	]])
	eq(child.lua_get([[vim.tbl_map(function(i) return i.text end, _G.opts.items)]]), { 'a [No Name]:2: two' })
end

T['junkfiles'] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			-- 実際のメモ置き場を汚さないよう、一時ディレクトリをキャッシュディレクトリにする
			child.lua([[
				local tmp = vim.fn.tempname()
				vim.fn.mkdir(tmp, 'p')
				vim.env.XDG_CACHE_HOME = vim.fn.resolve(tmp)
				_G.junk = function(name, lines, mtime)
					local path = require('my.junkfile').dir() .. '/' .. name
					vim.fn.mkdir(vim.fs.dirname(path), 'p')
					vim.fn.writefile(lines, path)
					vim.uv.fs_utime(path, mtime, mtime)
				end
			]])
		end,
	},
})

T['junkfiles']['月ごとのメモと話題ごとのメモを最近更新した順に並べる'] = function()
	child.lua([[
		junk('2026/10/main.md', { 'old' }, 1000)
		junk('topics/perl.md', { 'newest' }, 3000)
		junk('2026/11/2026-11-18.md', { 'middle' }, 2000)
		sources.junkfiles()
	]])
	eq(child.lua_get([[vim.tbl_map(function(i) return i.text end, _G.opts.items)]]),
		{ 'topics/perl.md', '2026/11/2026-11-18.md', '2026/10/main.md' })
end

T['junkfiles']['メモが無くても空の一覧を開く'] = function()
	child.lua([[sources.junkfiles()]])
	eq(child.lua_get([[#_G.opts.items]]), 0)
end

T['junkfiles']['中身の grep はメモの置き場所を対象にする'] = function()
	skip_without_rg()
	child.lua([[
		junk('topics/perl.md', { 'use strict;' }, 1000)
		sources.junkgrep()
	]])
	local dir = child.lua_get([[require('my.junkfile').dir()]])
	eq(child.lua_get([[vim.api.nvim_win_get_config(_G.f.input_wins[1]).title[1][1] ]]),
		' Grep: ' .. child.fn.fnamemodify(dir, ':~') .. ' ')
	child.type_keys('strict')
	child.lua([[vim.wait(3000, function() return #_G.f.items > 0 and not _G.f.loading end)]])
	eq(child.lua_get([[_G.f.items[1].file]]), dir .. '/topics/perl.md')
end

return T
