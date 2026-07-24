local M = {}

--- Default keyword table. Each entry names the highlight group applied to
--- that keyword and the group it links to for its color, so no hex value
--- has to be invented — the link target already exists in every
--- colorscheme, and `default = true` (see `M.setup_highlights`) lets a
--- user's own colorscheme override it.
M.keywords = {
    TODO = { hl_group = 'CommentKeywordTodo', link = 'DiagnosticInfo' },
    FIX = { hl_group = 'CommentKeywordFix', link = 'DiagnosticError' },
    HACK = { hl_group = 'CommentKeywordHack', link = 'DiagnosticWarn' },
    NOTE = { hl_group = 'CommentKeywordNote', link = 'DiagnosticHint' },
}

--- Register the highlight groups. Idempotent and safe to call repeatedly
--- (e.g. from a `ColorScheme` autocmd) without erroring.
function M.setup_highlights()
    for _, keyword in pairs(M.keywords) do
        vim.api.nvim_set_hl(0, keyword.hl_group, { link = keyword.link, default = true })
    end
end

return M
