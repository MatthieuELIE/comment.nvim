local scanner = require('comment.scanner')
local keywords = require('comment.keywords')

local function get_marks(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, scanner.namespace, 0, -1, { details = true })
end

describe('comment.scanner', function()
    it('highlights a keyword occurrence at the correct byte range', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
        assert.are.equal(0, marks[1][2]) -- row
        assert.are.equal(0, marks[1][3]) -- start col
        assert.are.equal(4, marks[1][4].end_col)
        assert.are.equal(keywords.keywords.TODO.hl_group, marks[1][4].hl_group)
    end)

    it('makes no highlight calls when the buffer has no keyword occurrences', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'just a regular line' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(0, #marks)
    end)

    it('clears previous highlights before reapplying, without stacking', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        scanner.scan(bufnr)
        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
    end)

    it('matches TODO only on a word boundary followed by a colon, uppercase-only, no false positives', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODOList and todos are not TODO matches, but TODO: is' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
    end)

    it('lines up byte offsets correctly when accented characters precede the keyword', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'café TODO: fix' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        -- 'café' is 5 bytes (é is 2 bytes in UTF-8) + 1 space = byte col 6.
        assert.are.equal(1, #marks)
        assert.are.equal(6, marks[1][3])
        assert.are.equal(10, marks[1][4].end_col)
    end)
end)
