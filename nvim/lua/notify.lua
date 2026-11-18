-- nvim-notify と同じ require('notify') で my.notify を呼べるようにする互換モジュール。
-- noice はメッセージを通知として出すとき、require('notify') が読み込める場合だけそれを使い、
-- 無ければ mini 表示に回す。ここで受けることで、echo やエラーも my.notify に集める。
-- noice が渡してくる render / on_open などの nvim-notify 固有のオプションは使わない
local notify = require('my.notify')

return setmetatable({
	dismiss = function()
		notify.dismiss()
	end,
}, {
	__call = function(_, msg, level, opts)
		opts = opts or {}
		return notify.notify(msg, level, {
			title = opts.title,
			timeout = opts.timeout,
			-- noice は前の戻り値を replace に入れて、連続する echo を 1 つの通知にまとめる
			replace = type(opts.replace) == 'table' and opts.replace or nil,
		})
	end,
})
