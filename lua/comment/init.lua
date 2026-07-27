local config = require('comment.config')
local keywords = require('comment.keywords')
local autocmd = require('comment.autocmd')

local M = {}

--- Entry point. Merges `opts` over the defaults in `comment.config`, then
--- registers the keyword highlight groups and the autocmds that keep
--- highlights in sync while editing. Safe to call with no arguments or a
--- partial options table.
---@param opts table|nil
function M.setup(opts)
    config.merge(opts)
    keywords.setup_highlights()
    autocmd.setup()
end

return M
