local M = {}

--- Format a "TODO"-style comment for insertion into a buffer.
---
--- Pure function: takes the resolved commentstring as a parameter instead of
--- reading it off a buffer, so it can be unit tested without opening one.
--- Callers typically resolve `commentstring` via
--- `vim.filetype.get_option(ft, 'commentstring')` (Neovim >= 0.10), which
--- works from a filetype name alone.
---
--- Uses `commentstring:format(payload)` rather than
--- `commentstring:gsub('%%s', payload)`: gsub treats `%` in the replacement
--- string as an escape character, so it corrupts any payload containing a
--- literal `%`. `format` substitutes in place, which also makes two-sided
--- commentstrings (e.g. `/*%s*/`, `<!--%s-->`) work for free.
---
---@param keyword string
---@param text string
---@param commentstring string|nil
---@return string|nil comment `nil` if `commentstring` is missing/empty, or invalid
function M.format(keyword, text, commentstring)
    if commentstring == nil or commentstring == '' then
        return nil
    end

    local payload = ('%s: %s'):format(keyword, text)
    local ok, comment = pcall(string.format, commentstring, payload)
    if not ok then
        return nil
    end

    return comment
end

return M
