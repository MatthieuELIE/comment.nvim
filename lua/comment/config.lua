local M = {}

--- Default configuration. Empty for now; later EPICs populate this as
--- user-facing options land.
M.defaults = {}

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
