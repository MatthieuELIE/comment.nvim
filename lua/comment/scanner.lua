local keywords = require('comment.keywords')
local config = require('comment.config')
local treesitter = require('comment.treesitter')

local M = {}

--- Dedicated namespace for keyword extmarks. A single namespace lets
--- `nvim_buf_clear_namespace` drop an entire previous pass in one call, so
--- repeated scans never stack highlights.
M.namespace = vim.api.nvim_create_namespace('comment_nvim_keywords')

--- Scan `bufnr` for keyword occurrences and (re)apply highlights. When
--- `comments_only` is enabled, matches outside a comment node are skipped
--- — unless `treesitter.is_comment` can't tell (no parser for the buffer's
--- language, most commonly), in which case the filter fails open.
---@param bufnr integer
function M.scan(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)

    -- Read once per scan, not once per match.
    local comments_only = config.options.comments_only

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for row, line in ipairs(lines) do
        for keyword, spec in pairs(keywords.keywords) do
            local search_from = 1
            -- Uppercase-only match on a word boundary: the frontier pattern
            -- is Lua's equivalent of `\b`, since Lua patterns have none.
            local pattern = '%f[%w]' .. vim.pesc(keyword) .. '%f[%W]'
            while true do
                local start_col, end_col = line:find(pattern, search_from)
                if not start_col then
                    break
                end

                -- string.find is byte-based and extmark columns are
                -- byte-based, so no conversion is needed beyond 1-based ->
                -- 0-based (same conversion feeds is_comment's 0-based col).
                local is_comment = not comments_only or treesitter.is_comment(bufnr, row - 1, start_col - 1) ~= false

                if is_comment then
                    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, row - 1, start_col - 1, {
                        end_col = end_col,
                        hl_group = spec.hl_group,
                    })
                end

                search_from = end_col + 1
            end
        end
    end
end

return M
