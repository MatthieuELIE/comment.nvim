local M = {}

---@param raw_lines string[]
---@param opts table|nil
function M.show(raw_lines, opts)
    raw_lines = raw_lines or {}
    opts = opts or {}

    vim.fn.setqflist({}, ' ', {
        title = opts.title or 'TODO search',
        lines = raw_lines,
        efm = '%f:%l:%c:%m',
    })

    if #raw_lines == 0 then
        vim.notify('comment.nvim: no matches found', vim.log.levels.INFO)
        return
    end

    vim.cmd('botright copen')
end

return M
