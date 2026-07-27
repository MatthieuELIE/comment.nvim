# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `keymaps` config option (boolean, default `false`): registers
  `<leader>tt`/`tn`/`tf`/`th` keymaps for a quickfix search filtered to a
  single keyword (`TODO`/`NOTE`/`FIX`/`HACK` respectively).
- `require('comment').todo_quickfix(keywords, title)`: public function
  backing the keymaps above, for users who leave `keymaps = false` but want
  to bind their own keys.
- `line_hl_group` config option to tint the whole line containing a match,
  not just the keyword. Each keyword gets its own line highlight group
  (`CommentKeywordTodoLine`, etc.), linked from the keyword's own group but
  kept separate so it can be overridden independently for a background tint.

## [v0.1.0] - 2026-07-27

### Added

- Keyword highlighting for `TODO`, `FIX`, `HACK`, and `NOTE` comments, live
  on buffer enter/edit and re-applied on colorscheme change. Each keyword
  links to an existing Diagnostic highlight group.
- `comments_only` config option to restrict highlighting to TreeSitter
  comment nodes, falling back to highlighting everything if no parser is
  available for the buffer's filetype.
- `:TodoQuickFix` command: searches the project with ripgrep for the same
  keywords and shows the results in the quickfix list.
- `:TodoTelescope` command: same project search, shown in a Telescope
  picker; warns instead of erroring when Telescope isn't installed.
- `:TodoInsert` command: prompts for text and inserts it as a `TODO` comment
  on a new line below the cursor, using the buffer's `commentstring`.
