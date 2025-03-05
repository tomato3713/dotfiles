local sourceIdx = 1;

local source_list = {
	{ 'cmdline', 'shell_native', 'cmdline_history', 'file' },
	{ 'file' },
};

local current = function()
	return source_list[sourceIdx];
end

local next = function()
	sourceIdx = sourceIdx + 1
	if sourceIdx > #source_list then
		sourceIdx = 1
	end

	return current();
end

local reset = function()
	sourceIdx = 1
end

return {
	next = next,
	current = current,
	reset = reset,
}
