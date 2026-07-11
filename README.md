# My Neovim Configuration

This configuration aims to:

- Make the most of Neovim's built-in features, including themes and `vim.pack`.
- Avoid relying on the discontinued nvim-treesitter plugin.

## Tree-sitter

This configuration uses Zig to fetch and build Tree-sitter grammars from various sources. The
included query files have been adapted for use with Neovim.

To add a grammar, fetch its parser source with:

```shell
$ zig fetch --save=tree-sitter-[grammar] https://github.com/[owner]/[repo]/archive/[ref].tar.gz
```

Then, register the grammar in `grammars.json` and specify the filetypes for which it should be
enabled.
