local augend = require("dial.augend")
require("dial.config").augends:register_group {
	default = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.alias["%Y/%m/%d"],
	},
	go = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.constant.new { elements = { "true", "false" } },
		augend.constant.new { elements = { "var", "const" } },
	},
	typescript = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.constant.new { elements = { "true", "false" } },
		augend.constant.new { elements = { "let", "const" } },
	},
	lua = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.constant.new { elements = { "true", "false" } },
	},
	visual = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.alias["%Y/%m/%d"],
		augend.constant.alias.alpha,
		augend.constant.alias.Alpha,
	},
}

-- change augends in VISUAL mode
vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual("visual"), { noremap = true })
vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual("visual"), { noremap = true })

require('my.utils').nvim_create_autocmd({ 'FileType' }, {
	pattern = 'typescript',
	callback = function()
		vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal("typescript"),
			{ noremap = true, buffer = true })
		vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal("typescript"),
			{ noremap = true, buffer = true })
	end
})

require('my.utils').nvim_create_autocmd({ 'FileType' }, {
	pattern = 'lua',
	callback = function()
		vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal("lua"),
			{ noremap = true, buffer = true })
		vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal("lua"),
			{ noremap = true, buffer = true })
	end
})

require('my.utils').nvim_create_autocmd({ 'FileType' }, {
	pattern = 'go',
	callback = function()
		vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal("go"),
			{ noremap = true, buffer = true })
		vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal("go"),
			{ noremap = true, buffer = true })
	end
})
