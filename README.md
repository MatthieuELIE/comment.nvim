# comment.nvim

A Neovim plugin that highlights and searches `TODO`/`FIX`/`HACK`/`NOTE`
comments, and lets you insert them with one command.

## Features

### Keyword highlighting

Occurrences of `TODO`, `FIX`, `HACK`, and `NOTE` are highlighted as you
open and edit a buffer (`BufEnter`/`BufWinEnter`, debounced on
`TextChanged`/`TextChangedI`), and re-registered on `ColorScheme` reload.
Each keyword links to an existing Diagnostic highlight group by default, so
your colorscheme's own colors are used.

Set `comments_only = true` to only highlight matches inside a TreeSitter
comment node (falls back to highlighting everything if no parser is
available for the buffer's filetype):

```lua
require('comment').setup({ comments_only = true })
```

### Project-wide search

`:TodoQuickFix` and `:TodoTelescope` run [ripgrep](https://github.com/BurntSushi/ripgrep)
over the current project for the same `TODO`/`FIX`/`HACK`/`NOTE` keywords and
display the results in the quickfix list or a
[Telescope](https://github.com/nvim-telescope/telescope.nvim) picker,
respectively. `:TodoTelescope` requires Telescope to be installed; without
it, a warning is shown instead of erroring.

### Quick todo insertion

`:TodoInsert` prompts for a line of text and inserts it as a `TODO` comment
on a new line below the cursor, indented to match the current line. The
comment is formatted using the current buffer's `commentstring`, so it works
correctly for both single-sided (`-- %s`) and two-sided (`/*%s*/`,
`<!--%s-->`) comment styles. If the filetype has no `commentstring`, nothing
is inserted and a warning is shown instead.

No default keymap is bound, to avoid clashing with your own config. Map it
yourself, e.g.:

```lua
vim.keymap.set('n', '<leader>td', '<cmd>TodoInsert<cr>', { desc = 'Insert todo comment' })
```

## Requirements

Neovim >= 0.10 (the plugin relies on `vim.system`, `vim.filetype.get_option`,
and `vim.uv`, all added in that release).

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) — add this spec to the list passed to `require('lazy').setup({...})`:

```lua
{
    'MatthieuELIE/comment.nvim',
    opts = {},
}
```

Using [vim.pack](https://neovim.io/doc/user/pack.html) (built into Neovim >= 0.12, no plugin manager needed) — drop this straight into `init.lua`:

```lua
vim.pack.add({ 'https://github.com/MatthieuELIE/comment.nvim' })
require('comment').setup({})
```

Note: unlike lazy.nvim's `opts = {}`, `vim.pack` has no auto-setup hook —
you must call `require('comment').setup()` yourself, as above.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for running tests, lint, and CI
locally.
