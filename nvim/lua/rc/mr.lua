-- do not record mr list
local no_record_list = {
	---@param filename string
	---@return boolean
	function(filename)
		return not (string.find(filename, "doc/.*%.txt$")
			or string.find(filename,"doc/.*%.jax$")
			or string.find(filename, "/.git/COMMIT_EDITMSG")
		)
	end,
}

vim.g["mr#mru#predicates"] = no_record_list
vim.g["mr#mrw#predicates"] = no_record_list
vim.g["mr#mrr#predicates"] = no_record_list
