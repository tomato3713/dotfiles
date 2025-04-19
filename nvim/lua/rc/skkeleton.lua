local skk_dir = '~/.config/skk'
local global_skk_jisyo = vim.fn.expand(skk_dir .. '/SKK-JISYO.L')
local user_skk_jisyo = vim.fn.expand(skk_dir .. '/user.dict')

local init_skk_dictionary = function(global_dictionary_path, is_override)
	local dictionary_url = 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'
	require('my.utils').download_file(dictionary_url, global_dictionary_path, is_override)
end

local init = function()
	vim.fn['skkeleton#config']({
		eggLikeNewline = true,
		keepState = false,
		globalDictionaries = {
			{ global_skk_jisyo, 'euc-jp' },
		},
		userDictionary = user_skk_jisyo,
		immediatelyDictionaryRW = true,
		markerHenkan = '|',
		markerHenkanSelect = '?'
	})

	vim.fn['skkeleton#register_kanatable']('rom', {
		["z."] = { "．" },
		["z,"] = { "，" },
		["z<Space>"] = { "　" },
		["z("] = { "（" },
		["z)"] = { "）" },
	})
end

vim.api.nvim_create_user_command('DownloadSKKDict', function()
	init_skk_dictionary(global_skk_jisyo, true)
end, {})

require('my.utils').nvim_create_autocmd('User', {
	pattern = 'skkeleton-initialize-pre',
	callback = init,
	desc = 'init skkeleton',
})

init_skk_dictionary(global_skk_jisyo, false)

init()
