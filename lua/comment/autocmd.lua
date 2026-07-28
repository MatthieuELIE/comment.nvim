local scanner = require('comment.scanner')
local keywords = require('comment.keywords')

local M = {}

-- ponytail: TextChangedI fires on every keystroke and scan() re-reads the
-- whole buffer; debounce collapses a typing burst into one scan instead of
-- one per keystroke. Switch to visible-range scanning if this debounce
-- turns out not to be enough on very large files.
local DEBOUNCE_MS = 100

local timers = {}

local function schedule_scan(bufnr)
    local pending = timers[bufnr]
    if pending then
        pending:stop()
    end
    timers[bufnr] = vim.defer_fn(function()
        timers[bufnr] = nil
        if vim.api.nvim_buf_is_valid(bufnr) then
            scanner.scan(bufnr)
        end
    end, DEBOUNCE_MS)
end

function M.setup()
    local group = vim.api.nvim_create_augroup('CommentNvim', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        group = group,
        callback = function(args)
            scanner.scan(args.buf)
        end,
    })

    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = group,
        callback = function(args)
            schedule_scan(args.buf)
        end,
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = function()
            keywords.setup_highlights()
        end,
    })
end

return M
