-- 保存する前に一度だけ整形する。
-- 以前は保存した後に FormatWrite で整形して書き直していたため、保存のたびに 2 回書き込んでいた
local conform = require('conform')

conform.setup({
	formatters_by_ft = {
		-- lua は専用のフォーマッタを入れず、LuaLS の整形を使う
		lua = { lsp_format = 'fallback' },
		go = { 'gofmt' },
		perl = { 'perltidy' },
		sql = { 'sql_formatter' },
		-- 専用のフォーマッタが無いものも、末尾の空白だけは消す
		typescriptreact = { 'trim_whitespace' },
		scss = { 'trim_whitespace' },
	},
	format_on_save = {
		timeout_ms = 1000,
	},
})

vim.keymap.set('n', '<Space>f', function()
	conform.format({ lsp_format = 'fallback' })
end, { desc = 'format buffer' })
