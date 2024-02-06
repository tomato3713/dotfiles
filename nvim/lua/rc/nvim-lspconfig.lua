local nvim_lsp = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

require('mason').setup({
	ui = { icons = { package_installed = "＊", package_pending = "∴", package_uninstalled = "×" } }
})

-- vim.lsp.log_levels = 0

-- LSPの警告フォーマット
-- ref: https://dev.classmethod.jp/articles/eetann-change-neovim-lsp-diagnostics-format/
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	silent = true,
	border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	silent = true,
	border = "single",
})
vim.diagnostic.config({
	float = { border = "single" },
})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<Space>df", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>f", function() require("rc.utils").keep_cursor(vim.lsp.buf.format) end,
	{ noremap = true, silent = true })

local on_attach = function(_, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- code reading
	-- show information at cursor
	--- 定義情報などを表示する
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	--- 関数の引数の内容とかを表示する
	vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)
	--- カーソル行のエラーを表示
	vim.keymap.set("n", "gs", vim.diagnostic.open_float, bufopts)

	-- code walking
	--- 前のエラーに移動
	vim.keymap.set("n", "g[", "<cmd>lua vim.lsp.buf.diagnostic.show_prev()<CR>", bufopts)
	--- 次のエラーに移動
	vim.keymap.set("n", "g]", "<cmd>lua vim.lsp.buf.diagnostic.show_next()<CR>", bufopts)

	-- code edit
	--- 関数名や変数名をリネーム
	vim.keymap.set("n", "<Space>r", "<cmd>lua vim.lsp.buf.rename()<CR>", bufopts)

	-- workspace
	--- ワークスペース一覧を表示
	vim.keymap.set("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
	--- ワークスペースにフォルダを追加する
	vim.keymap.set("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
	vim.keymap.set("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
end

-- Perl root > Git repository root > current directory
local perl_root_dir = function(pattern)
	local root =
	    nvim_lsp.util.root_pattern(".perl-version", ".perltidyrc", ".perlcriticrc", "cpanfile", ".git")(pattern)
	local cwd = vim.loop.cwd()

	return root or cwd
end

mason_lspconfig.setup_handlers({
	function(server_name)
		-- tsserverとdenolsを出し分ける
		local deno_root_dir = nvim_lsp.util.root_pattern("deno.json")
		local is_deno_repo = deno_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

		local opts = {}
		if server_name == "tsserver" then
			if is_deno_repo then
				return
			end
			opts.root_dir = deno_root_dir
		elseif server_name == "eslint" then
			if is_deno_repo then
				return
			end
			opts.root_dir = deno_root_dir
		elseif server_name == "denols" then
			if not is_deno_repo then
				return
			end
			opts.root_dir = nvim_lsp.util.root_pattern(
				"deno.json",
				"deno.jsonc",
				"deps.ts",
				"import_map.json",
				"denops"
			)
			opts.init_options = {
				lint = true,
				unstable = true,
				suggest = {
					imports = {
						hosts = {
							["https://deno.land"] = true,
							["https://cdn.nest.land"] = true,
							["https://crux.land"] = true,
						},
					},
				},
			}
		end

		if server_name == "perlnavigator" then
			opts = {
				cmd = { "perlnavigator", "--stdio" },
				single_file_support = true,
				root_dir = perl_root_dir,
				settings = {
					perlnavigator = {
						perlPath = vim.env.HOME .. "/.plenv/shims/perl",
						includeLib = true,
						includePaths = {
							"$workspaceFolder/local/lib/perl5",
							"$workspaceFolder/local/lib/perl5/darwin-2level",
							"$workspaceFolder/lib",
						},
						perlImportsTidyEnabled = true,
						perlTidyEnabled = true,
						perlcriticEnabled = true,
						enableWarnings = true,
					},
				},
			}
		end

		opts.on_attach = on_attach

		nvim_lsp[server_name].setup(opts)
	end,
})

-- has no completion capability
nvim_lsp.perlls.setup({
	on_attach = on_attach,
	root_dir = perl_root_dir,
	cmd = {
		vim.env.HOME .. "/.plenv/shims/perl",
		"-MPerl::LanguageServer",
		"-e",
		"Perl::LanguageServer::run",
		"--",
		-- "--debug",
		"--port 27011",
		-- "--nostdio 0",
		-- "--enable",
	},
	settings = {
		perl = {
			perlCmd = vim.env.HOME .. "/.plenv/shims/perl",
			perlInc = {
				-- https://github.com/richterger/Perl-LanguageServer#module-not-found-when-debugging-or-during-syntax-check
				-- set to a fixed absolute path
				perl_root_dir(vim.api.nvim_buf_get_name(0)) .. "/lib",
				perl_root_dir(vim.api.nvim_buf_get_name(0)) .. "/local/lib/perl5",
				perl_root_dir(vim.api.nvim_buf_get_name(0)) .. "/local/lib/perl5/darwin-2level/",
			},
			ignoreDirs = {
				".git",
				".vscode", -- create cache files in this directory.
				"tmp",
				".tmp",
				"node_modules",
			},
			enable = true,
		},
	},
})
