local nvim_lsp = require('nvim_lsp')
local diagnostic = require('diagnostic')
local lsp_status = require('lsp-status')
local completion = require('completion')

local on_attach = function(client, bufnr)
    lsp_status.on_attach(client, bufnr)
    diagnostic.on_attach(client, bufnr)
    completion.on_attach(client, bufnr)

    -- Keybindings for LSPs
    -- Note these are in on_attach so that they don't override bindings in a non-LSP setting
    vim.fn.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", {noremap = true, silent = true})
    vim.fn.nvim_set_keymap("n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", {noremap = true, silent = true})
end

lsp_status.register_progress()
lsp_status.config({
    status_symbol = '',
    indicator_errors = 'e',
    indicator_warnings = 'w',
    indicator_info = 'i',
    indicator_hint = 'h',
    indicator_ok = 'ok',
    spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
})

nvim_lsp.sumneko_lua.setup{
    on_attach = on_attach,
	cmd = {vim.env.HOME .. "\\.vscode\\extensions\\sumneko.lua-0.21.6\\server\\bin\\Windows\\lua-language-server.exe", "-E", vim.env.HOME .. "\\.vscode\\extensions\\sumneko.lua-0.21.6\\server\\main.lua"},
    settings = {
        Lua = {
            diagnostics = {
                globals = {"vim"}
            }
        }
    }
}
nvim_lsp.gopls.setup({
    on_attach = on_attach,
})
nvim_lsp.texlab.setup({
    on_attach = on_attach,
})

-- More language servers here! ...

