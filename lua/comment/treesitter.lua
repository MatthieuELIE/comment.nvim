local M = {}

---@param bufnr integer
---@param row integer
---@param col integer
---@return boolean|nil
function M.is_comment(bufnr, row, col)
    local ok, result = pcall(function()
        local parser = vim.treesitter.get_parser(bufnr)
        if not parser then
            return nil
        end

        local query = vim.treesitter.query.get(parser:lang(), 'highlights')
        if not query then
            return nil
        end

        local trees = parser:parse({ row, 0, row + 1, 0 })
        if not trees or not trees[1] then
            return nil
        end

        for id, node in query:iter_captures(trees[1]:root(), bufnr, row, row + 1) do
            if query.captures[id] == 'comment' then
                local start_row, start_col, end_row, end_col = node:range()
                local after_start = row > start_row or (row == start_row and col >= start_col)
                local before_end = row < end_row or (row == end_row and col < end_col)
                if after_start and before_end then
                    return true
                end
            end
        end

        return false
    end)

    if not ok then
        return nil
    end
    return result
end

return M
