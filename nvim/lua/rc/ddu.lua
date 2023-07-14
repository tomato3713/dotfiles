local M = {}

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
			displayTree = true,
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
			displayTree = true,
			split = 'floating',
		},
	},
})

local function resize()
	local lines = vim.opt.lines:get()
	local height, row = math.floor(lines * 0.5), math.floor(lines * 0.1)
	local previewHeight = math.floor(height * 1.3)
	local columns = vim.opt.columns:get()
	local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
	local previewWidth = math.floor(width / 3 * 2)

	vim.fn['ddu#custom#patch_global']({
		uiParams = {
			ff = {
				winHeight = height,
				winRow = row,
				winWidth = width,
				winCol = col,
				previewHeight = previewHeight,
				previewRow = row + 2,
				previewWidth = previewWidth,
				previewCol = col + (width - previewWidth - 5),
			},
		},
	})
end
resize()

vim.api.nvim_create_autocmd("VimResized", {
	callback = resize,
})

return M
