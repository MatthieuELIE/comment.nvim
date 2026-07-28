local M = {}

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

function M.setup_highlights()
    for _, keyword in pairs(M.keywords) do
        vim.api.nvim_set_hl(0, keyword.hl_group, { link = keyword.link, default = true })
        vim.api.nvim_set_hl(0, keyword.line_hl_group, { link = keyword.hl_group, default = true })
    end
end

return M
