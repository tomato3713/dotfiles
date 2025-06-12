vim.g["dps_dial#augends"] = {
	'decimal',
	'date-slash',
	{ kind = 'constant', opts = { elements = { 'true', 'false' }, cyclic = true, word = false } },
	{ kind = 'constant', opts = { elements = { 'left', 'right' }, cyclic = true, word = false } },
	{ kind = 'constant', opts = { elements = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' }, cycle = true, word = true } },
	{ kind = 'constant', opts = { elements = { 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday' }, cycle = true, word = true } },
	{ kind = 'case',     opts = { cases = { 'camelCase', 'snake_case' }, cyclic = true } },
}

require('my.utils').nvim_create_autocmd({ 'FileType' }, {
	pattern = 'typescript',
	callback = function()
		vim.b["dps_dial#augends"] = {
			{ kind = 'constant', opts = { elements = { 'let', 'const' }, cyclic = true, word = true } },
		}
	end
})
