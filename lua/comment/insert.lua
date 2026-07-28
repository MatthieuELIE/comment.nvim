local M = {}

---@param keyword string
---@param text string
---@param commentstring string|nil
---@return string|nil
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
