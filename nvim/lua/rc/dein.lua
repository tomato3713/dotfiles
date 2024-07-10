local _M = {}

_M.dein_loaded = false

-- dein Scripts
local dein_dir = vim.fn.expand('~/.cache/dein')
local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

_M.setup_mapping = function()
	vim.api.nvim_create_user_command('DeinClearCache', function()
		if not (_M.dein_loaded) then return end
		require('dein').recache_runtimepath()
	end, {})
end

--- init dein.vim
_M.init = function()
	if (_M.dein_loaded) then return end

	-- https://github.com/settings/tokens
	vim.api.nvim_set_var('dein#install_github_api_token', os.getenv('DEIN_GITHUB_TOKEN'))

	local current_runtimepath = vim.api.nvim_get_option_value('runtimepath', { scope = 'global' })
	vim.api.nvim_set_option_value('runtimepath', dein_repo_dir .. ',' .. current_runtimepath, { scope = 'global' })

	-- if not installed dein.vim, install.
	if not (vim.fn.isdirectory(dein_repo_dir) == 1) then
		local result = os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
		if (result) then
			print('dein was installed in:', dein_repo_dir)
		else
			print('failed to install dein')
		end
	end

	local dein = require('dein')

	dein.setup({
		auto_remote_plugins = false,
		enable_notification = true,
	})

	dein.begin(dein_dir)
	dein.load_toml(vim.fn.expand('~/.config/nvim/colorscheme.toml'), { lazy = 0 })
	dein.load_toml(vim.fn.expand('~/.config/nvim/dein.toml'), { lazy = 0 })
	dein.load_toml(vim.fn.expand('~/.config/nvim/ai.toml'), { lazy = 0 })
	dein.load_toml(vim.fn.expand('~/.config/nvim/ddu.toml'), { lazy = 1 })
	dein.load_toml(vim.fn.expand('~/.config/nvim/ddc.toml'), { lazy = 1 })
	dein.end_()
	dein.save_state()

	if dein.check_install() then
		dein.install()
	end

	local removed_plugins = dein.check_clean()
	if vim.fn.len(removed_plugins) > 0 then
		vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
		dein.recache_runtimepath()
	end
end

return _M
