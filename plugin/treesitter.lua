vim.treesitter.language.register("elixir", { "ex", "exs" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "elixir",
  callback = function()
    vim.treesitter.start()
  end,
})
