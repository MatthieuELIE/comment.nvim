# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.2.1] - 2026-07-28

### Fixed

- `:TodoQuickFix` and `:TodoTelescope` now pass `--hidden` to ripgrep, so
  keyword markers in dotfiles-repo layouts (e.g.
  `~/dotfiles/.config/nvim/...`) are found instead of silently skipped;
  `.git` stays excluded.

## [v0.2.0] - 2026-07-28

### Added

- `require('comment').todo_quickfix(keywords, title)`: public function so
  users can bind their own keys to a quickfix search filtered to one or
  more keywords.
- `require('comment').insert.{todo,note,fix,hack}()`: public functions to
  insert a `TODO`/`NOTE`/`FIX`/`HACK` comment, one per keyword, so users
  can bind their own keys instead of only having `:TodoInsert` for `TODO`.
- `line_hl_group` config option to tint the whole line containing a match,
  not just the keyword. Each keyword gets its own line highlight group
  (`CommentKeywordTodoLine`, etc.), linked from the keyword's own group but
  kept separate so it can be overridden independently for a background tint.
- Sign-column indicator per keyword: each match now also places a default
  sign glyph (`T`/`N`/`F`/`H`) colored with the keyword's own highlight
  group, visible when 'signcolumn' is enabled. Overridable per keyword via
  the new `signs` config table; an invalid override (not 1-2 display cells)
  warns and falls back to the default letter instead of erroring.

### Fixed

- Keyword highlighting, signs, and quickfix/Telescope search now require a
  marker colon (`TODO:`) instead of matching the bare keyword anywhere in
  the line — a line like `-- this TODO thing needs work` is no longer
  highlighted or returned as a match.

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
