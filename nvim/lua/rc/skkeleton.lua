vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-toggle)')
vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-toggle)')

local skk_dir = vim.fn.expand('~/.config/skk')
local global_skk_jisyo = skk_dir .. '/SKK-JISYO.L'
local user_skk_jisyo = skk_dir .. '/user-dict'
local skk_dict_url = 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'

-- download skk dictionary file
if not (vim.fn.isdirectory(skk_dir) == 1) then
	vim.fn.mkdir(skk_dir)
	os.execute('!curl' .. skk_dict_url .. '-o' .. vim.fn.expand(global_skk_jisyo))
end

vim.fn["denops#plugin#wait_async"]("skkeleton", function()
	vim.fn['skkeleton#config']({
		eggLikeNewline = true,
		keepState = false,
		globalJisyo = global_skk_jisyo,
		userJisyo = user_skk_jisyo,
		immediatelyJisyoRW = false,
		markerHenkan = '|',
		markerHenkanSelect = '?'
	})

	vim.fn['skkeleton#register_kanatable']('rom', {
		["z."] = { "．", '' },
		["z,"] = { "，", '' },
		["z<Space>"] = { "　", '' },
	})

	vim.fn['skkeleton#initialize']()
end)
