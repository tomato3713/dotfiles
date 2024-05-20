require("CopilotChat").setup({
	show_help = "yes",
	prompts = {
		Explain = {
			prompt = "/COPILOT_EXPLAIN 上記のコードを日本語で説明してください",
		},
		Review = {
			prompt = '/COPILOT_REVIEW 選択したコードをレビューしてください。説明は日本語でお願いします。',
		},
		Fix = {
			prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
		},
		Optimize = {
			prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします。",
		},
		Docs = {
			prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
		},
		Tests = {
			prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
		},
		FixDiagnostic = {
			prompt = 'コードの診断結果に従って問題を修正してください。',
			selection = require('CopilotChat.select').diagnostics,
		},
		Commit = {
			prompt =
			'commitize の規則に従って、変更に対するコミットメッセージを記述してください。 タイトルは最大50文字で、メッセージは72文字で折り返されるようにしてください。 メッセージ全体を gitcommit 言語のコード ブロックでラップしてください。',
			selection = require('CopilotChat.select').gitdiff,
		},
		CommitStaged = {
			prompt =
			'commitize の規則に従って、変更に対するコミットメッセージを記述してください。 タイトルは最大50文字で、メッセージは72文字で折り返されるようにしてください。 メッセージ全体を gitcommit 言語のコード ブロックでラップしてください。',
			selection = function(source)
				return require('CopilotChat.select').gitdiff(source, true)
			end,
		},
	},
})
