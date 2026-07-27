local M = {}

--- Default configuration.
---@class comment.Options
---@field comments_only boolean Restrict keyword matches to comment nodes. Off by default.
---@field keymaps boolean Register `<leader>tt/tn/tf/th` keyword-filtered quickfix keymaps. Off by default.
---@field line_hl_group boolean Tint the whole line containing a match, not just the keyword. Off by default.
---@field signs table<string, string> Per-keyword sign-column glyph overrides, keyed by keyword name. Empty by default.
M.defaults = {
    comments_only = false,
    keymaps = false,
    line_hl_group = false,
    signs = {},
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
