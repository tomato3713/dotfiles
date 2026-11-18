local function miniView(pattern, kind)
	kind = kind or ""
	return {
		view = "mini",
		filter = {
			event = "msg_show",
			kind = kind,
			find = pattern,
		},
	}
end

require("noice").setup({
	messages = {
		view_search = "mini",
	},
	-- vim.notify は my.notify が直接受け持つ。
	-- echo やエラーなどの「notify」表示も、互換モジュール lua/notify.lua を通して my.notify に出る
	notify = {
		enabled = false,
	},
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
	routes = {
	miniView("search hit .*, continuing at", "wmsg"),
	},
})
