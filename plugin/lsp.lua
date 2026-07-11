vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.enable("dexter")
vim.lsp.enable("elp")
vim.lsp.enable("gopls")
vim.lsp.enable("ruff")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("zls")

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}), 
	callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '<Space>lD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<Space>ld', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<Space>lR', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<Space>lr', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<Space>lh', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<Space>li', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<Space>ls', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<Space>lwa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<Space>lwr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<Space>lf', function()
            vim.lsp.buf.format { async = true }
          end, opts)
          vim.keymap.set({ 'n', 'v' }, '<Space>lc', vim.lsp.buf.code_action, opts)
	end
})
