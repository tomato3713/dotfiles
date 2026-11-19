require('gitsigns').setup({
	signs = {
		add          = { text = '+' },
		change       = { text = '*' },
		delete       = { text = '-' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	current_line_blame_formatter = '<author>|<author_time:%Y-%m-%d> - <summary>',
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
		delay = 50,
		ignore_whitespace = false,
	},
	preview_config = {
		style = 'minimal',
		relative = 'cursor',
		row = 1,
		col = 10,
		height = 25,
		width = 50,
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end
		-- ]d / [d は Neovim 標準の diagnostic 移動なので、diff モードと同じ ]c / [c に割り当てる
		map('n', ']c', function()
			if vim.wo.diff then
				vim.cmd.normal({ ']c', bang = true })
			else
				gs.nav_hunk('next')
			end
		end, { desc = 'goto git diff next hunk' })

		map('n', '[c', function()
			if vim.wo.diff then
				vim.cmd.normal({ '[c', bang = true })
			else
				gs.nav_hunk('prev')
			end
		end, { desc = 'goto git diff prev hunk' })

		map('n', '<space>b', function() gs.blame_line { full = true } end,
			{ desc = 'show blame current line' })
		map('n', '<space>gb', gs.toggle_current_line_blame, { desc = 'toggle current line blame' })
	end
})
