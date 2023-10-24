-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require('formatter').setup({
	-- Enable or disable logging
	logging = false,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		lua = {
			function()
				vim.lsp.buf.format({ async = false })
			end,
		},

		typescriptreact = {
			require('formatter.filetypes.typescriptreact').prettier,
		},

		typescript = {
			require('formatter.filetypes.typescript').prettier,
		},

		javascript = {
			require('formatter.filetypes.javascript').prettier,
		},

		css = {
			require('formatter.filetypes.css').prettier,
		},

		go = {
			require('formatter.filetypes.go').gofmt,
		},

		sql = {
			function()
				return {
					exe = 'sql-formatter',
					args = {
						'--fix',
					},
				}
			end,
		},

		perl = {
			function()
				return {
					exe = 'perltidy',
					args = {
						-- ファイルに出力せず、標準出力に出力する
						'-st',
					},
					stdin = true,
				}
			end,
		},

		-- Use the special "*" filetype for defining formatter configurations on
		-- any filetype
		['*'] = {
			-- "formatter.filetypes.any" defines default configurations for any
			-- filetype
			require('formatter.filetypes.any').remove_trailing_whitespace,
		},
	},
})
