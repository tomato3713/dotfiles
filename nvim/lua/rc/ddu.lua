local M = {}

--- https://zenn.dev/uga_rosa/articles/ace68bd6ba3480
---@class Source
---@field name string
---@field params? table

---@param word string
---@param color string
---@return Source
local function separator(word, color)
	local hlGroup = "DduDummy" .. color:gsub("[^a-zA-Z0-9]", "")
	vim.api.nvim_set_hl(0, hlGroup, { fg = color })
	return {
		name = "dummy",
		params = { word = word, hlGroup = hlGroup },
	}
end

---@param source_name string
---@param config? table
---@return function
function M.start(source_name, config)
	config = config or {}
	config.name = config.name or source_name
	-- TODO: support sources: string|string[]
	config.sources = config.sources or { { name = source_name } }
	return function()
		vim.fn['ddu#start'](config)
	end
end

vim.fn['ddu#custom#patch_global']({
	ui = 'ff',
	sources = {
		{ name = 'file_rec' },
		{ name = 'mr' },
		{ name = 'register' },
		{ name = 'buffer' },
	},
	sourceParams = {
		file_rec = { ignoredDirectories = { '.git', 'node_modules', 'vendor', '.next' } },
		rg = { args = { '--column', '--no-heading', '--color', 'never' } },
		joplin = { token = vim.env.JOPLIN_TOKEN, fullPath = true },
		joplin_tree = { token = vim.env.JOPLIN_TOKEN },
	},
	sourceOptions = {
		_ = {
			matchers = { 'matcher_kensaku' },
		},
		joplin = { columns = { 'joplin' } },
		joplin_tree = { columns = { 'joplin' } },
	},
	filterParams = {
		matcher_substring = { highhtMatched = 'Search' },
	},
	kindOptions = {
		help = { defaultAction = 'open' },
		file = { defaultAction = 'open' },
		joplin = { defaultAction = 'open' },
		lsp = { defaultAction = 'open' },
		lsp_codeAction = { defaultAction = 'apply' },
		colorscheme = { defaultAction = 'set' },
	},
	uiParams = {
		ff = {
			prompt = '>> ',
			startFilter = true,
			split = 'floating',
			autoAction = { name = "preview" },
			startAutoAction = true,
			previewFloating = true,
			previewFloatingBorder = "double",
			previewSplit = "vertical",
			previewFloatingTitle = "Preview",
			ignoreEmpty = true,
			floatingBorder = "single",
			highlights = {
				floatingBorder = "Verbose",
			},
		},
		filer = {
			statusline = false,
			displayRoot = false,
			displayTree = true,
			split = 'floating',
			floatingBorder = "single",
		},
	},
})

local function resize()
	local lines = vim.opt.lines:get()
	local height, row = math.floor(lines * 0.2), math.floor(lines * 0.1)
	local previewHeight = math.floor(lines - height - row - 2 - 5)
	local columns = vim.opt.columns:get()
	local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
	local previewWidth = width

	vim.fn['ddu#custom#patch_global']({
		uiParams = {
			ff = {
				winHeight = height,
				winRow = row,
				winWidth = width,
				winCol = col,
				previewHeight = previewHeight,
				previewRow = row + height + 2,
				previewWidth = previewWidth,
				previewCol = col
			},
		},
	})
end
resize()

vim.api.nvim_create_autocmd("VimResized", {
	callback = resize,
})

-- mappings
local res = {
	{ key = ',h',       name = 'help',           desc = 'ddu: help tags source' },
	{ key = ',m',       name = 'mr',             desc = 'ddu: mr source' },
	{ key = ',b',       name = 'buffer',         desc = 'ddu: buffer source' },
	{ key = ',f',       name = 'file_rec',       desc = 'ddu: file_rec source' },
	{ key = ',c',       name = 'colorscheme',    desc = 'ddu: colorscheme source' },
	{ key = ',j',       name = 'joplin',         desc = 'ddu: joplin source' },
	{ key = ',t',       name = 'joplin_tree',    config = { ui = 'filer' },          desc = 'ddu: joplin source' },
	{ key = '<Space>a', name = 'lsp_codeAction', desc = 'ddu: lsp codeAction source' },
	{ key = ',d',       name = 'lsp_diagnostic', desc = 'ddu: lsp diagnostics' },
}

for _, v in ipairs(res) do
	vim.keymap.set('n', v.key, M.start(v.name, v.config or {}), { silent = true, desc = v.desc })
end

-- ファイル検索開始
-- カーソル上のワードで grep
vim.keymap.set('n', ',g',
	function()
		local word = vim.fn.expand('<cword>')
		vim.fn['ddu#start']({
			name = 'grep',
			sources = {
				{
					name = 'rg',
					params = {
						input = word
					}
				}
			}
		})
	end,
	{ silent = true })

vim.keymap.set('n', ',k',
	function()
		local word = vim.fn.expand('<cword>')
		vim.fn['ddu#start']({
			name = 'joplin',
			sources = {
				{
					name = 'joplin',
					params = {
						input = word
					}
				}
			}
		}
		)
	end,
	{ silent = true })

-- sources from language server
vim.keymap.set('n', '<space>h',
	function()
		vim.fn['ddu#start']({
			name = 'lsp_callHierarchy',
			sources = {
				separator('>>callHierarchy/outgoingCalls<<', '#fc514e'),
				{
					name = 'lsp_callHierarchy',
					params = { method = 'callHierarchy/outgoingCalls' },
				},
				separator('>>callHierarchy/incommingCalls<<', '#5e97ec'),
				{
					name = 'lsp_callHierarchy',
					params = { method = 'callHierarchy/incommingCalls' },
				},
			},
		})
	end, { silent = true, desc = 'lsp_callHierarchy/outgoing and incomming calls' })

vim.keymap.set('n', 'gi',
	function()
		vim.fn['ddu#start']({
			name = 'lsp',
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/implementation',
				},
			},
		})
	end, { desc = 'textDocument/implementation' })

vim.keymap.set('n', 'gD',
	function()
		vim.fn['ddu#start']({
			name = 'lsp',
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/declaration',
				},
			},
		})
	end, { desc = 'textDocument/declaration' })

vim.keymap.set('n', 'gtd',
	function()
		vim.fn['ddu#start']({
			name = 'lsp',
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/typeDefinition',
				},
			},
		})
	end, { desc = 'textDocument/typeDefinition' })

vim.keymap.set('n', 'gd',
	function()
		vim.fn['ddu#start']({
			name = 'lsp',
			sources = {
				{
					name = 'lsp_definition',
					method = 'textDocument/definition',
				},
			},
		})
	end, { desc = 'textDocument/definition' })

vim.keymap.set('n', 'gr',
	function()
		vim.fn['ddu#start']({
			name = 'lsp',
			sources = {
				separator('>>Definition<<', '#fc514e'),
				{
					name = 'lsp_definition',
				},
				separator('>>References<<', '#fc514e'),
				{
					name = 'lsp_references',
					params = { includeDeclaration = false },
				},
			},
		})
	end, { desc = 'textDocument/definition' })
return M
