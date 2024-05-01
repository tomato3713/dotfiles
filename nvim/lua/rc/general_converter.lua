local utf8 = require('utf8')

require("general_converter").setup {
	converters = {
		{
			desc = "ひらがなに変換する (「あ」 -> 「あ」, 「ア」 -> 「あ」)",
			converter = function(str)
				local ret = ""
				for p, c in utf8.codes(str) do
					if c >= 0x30A1 and c <= 0x30F6 then
					ret = ret .. utf8.char(c + 0x60)
					else
						ret = ret .. utf8.char(c)
					end
				end
				return ret
			end,
			labels = { "hira" },
		},
		{
			desc = "Vim script の式とみなして計算する (1 + 1 -> 2, 40 * 3 -> 120)",
			converter = function(s)
				return vim.fn.string(vim.api.nvim_eval(s))
			end,
			labels = { "calc" },
		},
	},
}

vim.keymap.set(
	{ "n", "x" },
	"@k",
	require("general_converter").operator_convert("hira"),
	{ expr = true }
)

vim.keymap.set(
	{ "n", "x" },
	"@c",
	require("general_converter").operator_convert("calc"),
	{ expr = true }
)
