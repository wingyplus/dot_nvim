local path = vim.api.nvim_get_runtime_file("grammars.json", false)[1]
-- TODO: find a good way to read file more efficiency.
local grammars = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))

-- Register all grammars, defined in grammars.json
for _, grammar in ipairs(grammars) do
  vim.treesitter.language.register(grammar.name, grammar.filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = grammar.name,
    callback = function()
      vim.treesitter.start()
    end,
  })
end
