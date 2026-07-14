local filetypes = {
  elixir = { "elixir" },
  tsx = { "tsx" },
  typescript = { "typescript" },
  heex = { "heex" },
  yaml = { "yaml" },
}

-- Register all grammars, defined in grammars.json
for grammar, grammar_filetypes in pairs(filetypes) do
  vim.treesitter.language.register(grammar, grammar_filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = grammar_filetypes,
    callback = function()
      vim.treesitter.start()
    end,
  })
end
