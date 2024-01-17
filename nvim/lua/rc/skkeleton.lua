vim.keymap.set({ 'i', 'c', 't' }, '<C-j>', '<Plug>(skkeleton-toggle)')

local skk_dir = '~/.config/skk'
local global_skk_jisyo = vim.fn.expand(skk_dir .. '/SKK-JISYO.L')

-- download skk dictionary file
local download_global_skk_dictionary = function(global_dictionary)
	local skk_dict_url = 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'
	os.execute('curl ' .. skk_dict_url .. ' -o ' .. vim.fn.expand(global_dictionary))
end

local init_skk_dictionary = function(dir, global_dictionary)
	if not (vim.fn.isdirectory(dir) == 0) then
		vim.fn.mkdir(dir)

		download_global_skk_dictionary(global_dictionary)
	end
end

local init = function()
	vim.fn['skkeleton#config']({
		eggLikeNewline = true,
		keepState = false,
		globalDictionaries = { { global_skk_jisyo, 'euc-jp' } },
		immediatelyDictionaryRW = false,
		markerHenkan = '|',
		markerHenkanSelect = '?'
	})

	vim.fn['skkeleton#register_kanatable']('rom', {
		["z."] = { "．", '' },
		["z,"] = { "，", '' },
		["z<Space>"] = { "　", '' },
	})
end

vim.api.nvim_create_user_command('DownloadSKKDict', function()
	download_global_skk_dictionary(global_skk_jisyo)
end, {})

require('rc.utils').nvim_create_autocmd('User', {
	group = 'skkeleton-initialize-pre',
	callback = init,
	desc = 'init skkeleton',
})

init_skk_dictionary(skk_dir, global_skk_jisyo)

init()
