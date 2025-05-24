local helper = require('rc.helper.ddu')

return {
	{
		name = 'callHierarchy',
		opt = {
			sources = {
				helper.separator('>>callHierarchy/outgoingCalls<<', '#fc514e'),
				{
					name = 'lsp_callHierarchy',
					params = { method = 'callHierarchy/outgoingCalls' },
				},
				helper.separator('>>callHierarchy/incommingCalls<<', '#5e97ec'),
				{
					name = 'lsp_callHierarchy',
					params = { method = 'callHierarchy/incommingCalls' },
				},
			},
			uiParams = {
				ff = {
					displayTree = true,
				}
			},
		}
	},
	{
		name = 'references',
		opt = {
			sources = {
				helper.separator('>>Definition<<', '#fc514e'),
				{
					name = 'lsp_definition',
				},
				helper.separator('>>References<<', '#fc514e'),
				{
					name = 'lsp_references',
					params = { includeDeclaration = false },
				},
			},
		},
	},
	{
		name = 'implementation',
		opt = {
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/implementation',
				},
			},
		}
	},
	{
		name = 'declaration',
		opt = {
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/declaration',
				},
			},
		}
	},
	{
		name = 'typeDefinition',
		opt = {
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/typeDefinition',
				},
			},
		},
	},
	{
		name = 'definition',
		opt = {
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/definition',
				},
			},
		},
	},
}
