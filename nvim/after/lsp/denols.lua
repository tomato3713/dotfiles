-- root_dir は nvim-lspconfig 側で ts_ls と排他になるよう判定されるため上書きしない
return {
	settings = {
		deno = {
			lint = true,
			unstable = true,
			suggest = {
				names = true,
				paths = true,
				autoImports = true,
				imports = {
					autoDiscover = true,
					hosts = vim.empty_dict(),
				},
			},
		},
	},
}
