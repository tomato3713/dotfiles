local finder = require('my.finder')
local sources = require('my.finder.sources')
local lsp = require('my.finder.lsp')

vim.ui.select = finder.ui_select

local maps = {
	{ ',f', sources.files, 'finder: files' },
	{ ',h', sources.help, 'finder: help tags' },
	{ ',o', sources.mru, 'finder: most recently used files' },
	{ ',m', sources.marks, 'finder: marks' },
	{ ',b', sources.buffers, 'finder: buffers' },
	{ ',t', sources.tabs, 'finder: tabs' },
	{ ',c', sources.colorschemes, 'finder: colorschemes' },
	{ ',d', sources.diagnostics, 'finder: diagnostics' },
	{ ',j', sources.junkfiles, 'finder: junkfiles' },
	{ ',J', sources.junkgrep, 'finder: grep in junkfiles' },
	{ ',F', '<Cmd>VFiler -layout=floating<CR>', 'filer' },

	-- lsp
	-- code action は vim.ui.select() 経由でファインダーが使われる
	-- code action / rename は Neovim 標準の gra / grn を使う。
	-- 一覧を finder で出したいものは、標準の gr* と同じキーを上書きする (gr 単体にすると gr* の入力を待ってしまう)
	{ '<Space>h', lsp.call_hierarchy, 'lsp: call hierarchy' },
	{ 'gd', lsp.jump('textDocument/definition', 'Definition'), 'lsp: definition' },
	{ 'gD', lsp.jump('textDocument/declaration', 'Declaration'), 'lsp: declaration' },
	{ 'gri', lsp.jump('textDocument/implementation', 'Implementation'), 'lsp: implementation' },
	{ 'grt', lsp.jump('textDocument/typeDefinition', 'Type Definition'), 'lsp: type definition' },
	{ 'grr', lsp.references, 'lsp: definition and references' },
	{ '<Space>wl', lsp.workspace_folders, 'lsp: workspace folders' },
}

for _, m in ipairs(maps) do
	vim.keymap.set('n', m[1], m[2], { silent = true, desc = m[3] })
end

-- カーソル上の単語で grep する。短すぎる単語は誤爆しやすいので、検索パターンの入力から始める
vim.keymap.set('n', ',g', function()
	local word = vim.fn.expand('<cword>')
	sources.grep(#word > 2 and word or '')
end, { silent = true, desc = 'finder: grep' })
