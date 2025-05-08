local lspconfig = require("lspconfig")

-- Perl root > Git repository root > current directory
local perl_root_dir = function(bufnr, callback)
	local roots =
	    vim.fs.find({
		    ".perl-version", ".perltidyrc", ".perlcriticrc", "cpanfile", ".git" }, {
		    upward = true,
		    path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)))
	    })

	if #roots > 0 then
		callback(vim.fs.dirname(roots[1]))
	end
end

return {
	cmd = { "perlnavigator", "--stdio" },
	single_file_support = true,
	root_dir = perl_root_dir,
	settings = {
		perlnavigator = {
			-- perlPath = vim.env.HOME .. "/.plenv/shims/perl",
			includeLib = true,
			includePaths = {
				"$workspaceFolder/lib",
				"$workspaceFolder/local/lib/perl5",
				"$workspaceFolder/local/lib/perl5/darwin-2level",
			},
			perlImportsTidyEnabled = true,
			perlTidyEnabled = true,
			perlcriticEnabled = true,
			enableWarnings = true,
		},
	},
}
