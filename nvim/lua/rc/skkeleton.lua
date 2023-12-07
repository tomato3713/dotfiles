vim.keymap.set({ 'i', 'c', 't' }, '<C-j>', '<Plug>(skkeleton-toggle)')

local skk_dir = '~/.config/skk'
local global_skk_jisyo = vim.fn.expand(skk_dir .. '/SKK-JISYO.L')
local user_skk_jisyo = vim.fn.expand(skk_dir .. '/user-dict')

-- download skk dictionary file
local download_global_skk_dictionary = function(global_dictionary)
	local skk_dict_url = 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'
	os.execute('curl ' .. skk_dict_url .. ' -o ' .. vim.fn.expand(global_dictionary))
end

local init_skk_dictionary = function(dir, global_dictionary, user_dictionary)
	if not (vim.fn.isdirectory(dir) == 0) then
		vim.fn.mkdir(dir)

		download_global_skk_dictionary(global_dictionary)
		vim.fn.writefile({}, user_dictionary)
	end
end

vim.api.nvim_create_user_command('DownloadSKKDict', function()
	download_global_skk_dictionary(global_skk_jisyo)
end, {})

init_skk_dictionary(skk_dir, global_skk_jisyo, user_skk_jisyo)

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
