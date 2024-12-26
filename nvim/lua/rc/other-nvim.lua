require("other-nvim").setup({
	mappings = {
		-- builtin mappings
		"golang",
		"react",
		-- open storybook
		{
			pattern = "/components/(.*)/(.*).tsx$",
			target = "/components/%1/%2.stories.tsx",
			context = "storybook"
		}
	},
	transformers = {
		-- defining a custom transformer
		lowercase = function(inputString)
			return inputString:lower()
		end
	},
	style = {
		-- How the plugin paints its window borders
		-- Allowed values are none, single, double, rounded, solid and shadow
		border = "solid",

		-- Column separator for the window
		separator = "|",

		-- width of the window in percent. e.g. 0.5 is 50%, 1.0 is 100%
		width = 0.7,

		-- min height in rows.
		-- when more columns are needed this value is extended automatically
		minHeight = 2
	},
})

vim.api.nvim_set_keymap("n", "go", "<cmd>:Other<CR>", { noremap = true, silent = true })
