local M = {}

---@class comment.Options
---@field comments_only boolean
---@field line_hl_group boolean
---@field signs table<string, string>
M.defaults = {
    comments_only = false,
    line_hl_group = false,
    signs = {},
}

M.options = {}

---@param opts table|nil
---@return table
function M.merge(opts)
    M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
    return M.options
end

return M
