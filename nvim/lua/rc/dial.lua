local dial = require('my.dial')
local augend = dial.augends

dial.setup({
	augends = {
		augend.decimal(),
		augend.date_slash(),
		augend.constant({ 'true', 'false' }, { word = false }),
		augend.constant({ 'left', 'right' }, { word = false }),
		augend.constant({ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' }),
		augend.constant({ 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday' }),
		augend.case(),
	},
	-- 共通の augends より優先して使う
	filetype = {
		typescript = {
			augend.constant({ 'let', 'const' }),
		},
	},
})
