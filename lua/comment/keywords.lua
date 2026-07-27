local M = {}

--- Default keyword table: each entry names a highlight group linked to an
--- existing colorscheme group (see `M.setup_highlights`), so no hex value
--- is invented and a user's own colorscheme can still override it.
---
--- `line_hl_group` is separate from `hl_group` (not reused): `hl_group` is
--- foreground-only, and `line_hl_group` paints the whole line.
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
