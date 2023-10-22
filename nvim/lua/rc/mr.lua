-- do not record mr list
local no_record_list = {
	function(filename)
		return string.match(filename, "COMMIT_EDITMSG") ~= nil
	end,
}

vim.api.nvim_set_var("mr#mru#predicates", no_record_list)
vim.api.nvim_set_var("mr#mrw#predicates", no_record_list)
vim.api.nvim_set_var("mr#mrr#predicates", no_record_list)
