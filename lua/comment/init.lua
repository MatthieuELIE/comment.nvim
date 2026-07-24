local config = require('comment.config')

local M = {}

--- Entry point. Merges `opts` over the defaults in `comment.config`. Safe to
--- call with no arguments or a partial options table.
---@param opts table|nil
function M.setup(opts)
    config.merge(opts)
end

return M
