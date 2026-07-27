local autocmd = require('comment.autocmd')
local scanner = require('comment.scanner')

local function marks_for(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, scanner.namespace, 0, -1, {})
end

describe('comment.autocmd', function()
    it('invokes scanner.scan on BufEnter', function()
        autocmd.setup()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })
        vim.api.nvim_set_current_buf(bufnr)

        vim.api.nvim_exec_autocmds('BufEnter', { buffer = bufnr })
        local marks = marks_for(bufnr)

        assert.are.equal(1, #marks)
    end)

    it('invokes scanner.scan (debounced) on TextChanged/TextChangedI', function()
        autocmd.setup()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })
        vim.api.nvim_set_current_buf(bufnr)

        vim.api.nvim_exec_autocmds('TextChangedI', { buffer = bufnr })
        vim.wait(500, function()
            return #marks_for(bufnr) > 0
        end)
        local marks = marks_for(bufnr)

        assert.are.equal(1, #marks)
    end)

    it('re-registering (setup called again) does not duplicate autocmds', function()
        autocmd.setup()
        autocmd.setup()
        local buf_enter_autocmds = vim.api.nvim_get_autocmds({ group = 'CommentNvim', event = 'BufEnter' })

        assert.are.equal(1, #buf_enter_autocmds)
    end)
end)
