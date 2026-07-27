local M = {}

--- Default configuration.
---@class comment.Options
---@field comments_only boolean Restrict keyword matches to comment nodes. Off by default.
M.defaults = {
    comments_only = false,
}

--- Resolved options, set by `M.merge()` (called from `setup()`).
M.options = {}

--- Merge `opts` over `M.defaults` and store the result on `M.options`.
---@param opts table|nil
---@return table
function M.merge(opts)
    M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
    return M.options
end

return M
