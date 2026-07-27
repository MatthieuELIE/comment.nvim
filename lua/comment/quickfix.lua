local M = {}

--- Populate the quickfix list from raw `rg --vimgrep` lines (as returned by
--- `comment.search`'s second return value) and display it. Ripgrep's
--- vimgrep format is parsed natively via `efm`, so no manual quickfix entry
--- building is needed.
---
--- Uses the `' '` setqflist action, which replaces the list rather than
--- appending to it.
---
--- Empty input sets an empty list, notifies once, and does not open the
--- window — an empty quickfix window is just noise.
---@param raw_lines string[] raw `rg --vimgrep` output lines
---@param opts table|nil optional { title = string }
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
