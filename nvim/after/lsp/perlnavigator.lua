return {
	cmd = { 'perlnavigator', '--stdio' },
	-- Perl プロジェクトのルートを優先し、見つからなければ Git リポジトリのルートを使う
	root_markers = {
		{ '.perl-version', '.perltidyrc', '.perlcriticrc', 'cpanfile' },
		'.git',
	},
	settings = {
		perlnavigator = {
			includeLib = true,
			includePaths = {
				'$workspaceFolder/lib',
				'$workspaceFolder/local/lib/perl5',
				'$workspaceFolder/local/lib/perl5/darwin-2level',
			},
			perlImportsTidyEnabled = true,
			perlTidyEnabled = true,
			perlcriticEnabled = true,
			enableWarnings = true,
		},
	},
}
