local M = {}

--- Default keyword table: each entry names a highlight group linked to an
--- existing colorscheme group (see `M.setup_highlights`), so no hex value
--- is invented and a user's own colorscheme can still override it.
---
--- `line_hl_group` is a separate group from `hl_group`, not a reuse of it:
--- `hl_group` links to a `Diagnostic*` group, which is foreground-only in
--- most colorschemes, so applying it as `line_hl_group` (which paints the
--- whole line) would recolor the line's text rather than tint it. The
--- separate group gives users a dedicated override point instead.
---
--- `sign` is the default sign-column glyph. Unlike `line_hl_group`,
--- `hl_group` is reused directly as the sign's highlight group: a sign
--- glyph only needs a foreground color, so the same Diagnostic-linked
--- group that colors the keyword text is correct here too. `sign` itself
--- is overridable per keyword via `config.options.signs` (read at scan
--- time in scanner.lua, not mutated here — this table is module state
--- shared across `setup()` calls in tests).
M.keywords = {
    TODO = {
        hl_group = 'CommentKeywordTodo',
        link = 'DiagnosticInfo',
        line_hl_group = 'CommentKeywordTodoLine',
        sign = 'T',
    },
    FIX = {
        hl_group = 'CommentKeywordFix',
        link = 'DiagnosticError',
        line_hl_group = 'CommentKeywordFixLine',
        sign = 'F',
    },
    HACK = {
        hl_group = 'CommentKeywordHack',
        link = 'DiagnosticWarn',
        line_hl_group = 'CommentKeywordHackLine',
        sign = 'H',
    },
    NOTE = {
        hl_group = 'CommentKeywordNote',
        link = 'DiagnosticHint',
        line_hl_group = 'CommentKeywordNoteLine',
        sign = 'N',
    },
}

--- Register the highlight groups. Idempotent and safe to call repeatedly
--- (e.g. from a `ColorScheme` autocmd) without erroring.
function M.setup_highlights()
    for _, keyword in pairs(M.keywords) do
        vim.api.nvim_set_hl(0, keyword.hl_group, { link = keyword.link, default = true })
        vim.api.nvim_set_hl(0, keyword.line_hl_group, { link = keyword.hl_group, default = true })
    end
end

return M
