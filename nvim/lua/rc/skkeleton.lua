vim.keymap.set({ 'i', 'c', 't' }, '<C-j>', '<Plug>(skkeleton-toggle)')

local skk_dir = '~/.config/skk'
local global_skk_jisyo = vim.fn.expand(skk_dir .. '/SKK-JISYO.L')

-- download skk dictionary file
local download_global_skk_dictionary = function(global_dictionary)
	local skk_dict_url = 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'
	os.execute('curl ' .. skk_dict_url .. ' -o ' .. vim.fn.expand(global_dictionary))
end

local init_skk_dictionary = function(global_dictionary)
	if vim.fn.filereadable(vim.fn.expand(global_dictionary)) == 0 then
		vim.fn.mkdir(global_dictionary, "p")

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

require('rc.utils').nvim_create_autocmd("User", {
	pattern = "skkeleton-enable-post",
	callback = function()
		require('rc.helper.ddc').patch_buffer("sources", { "skkeleton" })
	end,
})

require('rc.utils').nvim_create_autocmd("User", {
	pattern = "skkeleton-disable-post",
	callback = function()
		require('rc.helper.ddc').remove_buffer("sources")
	end,
})

vim.api.nvim_create_user_command('DownloadSKKDict', function()
	download_global_skk_dictionary(global_skk_jisyo)
end, {})

require('rc.utils').nvim_create_autocmd('User', {
	pattern = 'skkeleton-initialize-pre',
	callback = init,
	desc = 'init skkeleton',
})

init_skk_dictionary(global_skk_jisyo)

init()
