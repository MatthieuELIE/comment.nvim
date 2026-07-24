local scanner = require('comment.scanner')
local comment = require('comment')

local function marks_for(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, scanner.namespace, 0, -1, {})
end

describe('comment.scanner comments_only filtering', function()
    it('highlights only comment-node matches when comments_only is true and a parser is available', function()
        comment.setup({ comments_only = true })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'lua'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            '-- TODO: real comment',
            "local s = 'TODO: not a comment'",
        })

        scanner.scan(bufnr)
        local marks = marks_for(bufnr)

        assert.are.equal(1, #marks)
    end)

    it('fails open (highlights everything) when comments_only is true but is_comment returns nil', function()
        comment.setup({ comments_only = true })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'a_filetype_with_no_treesitter_parser'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this', 'another TODO here' })

        scanner.scan(bufnr)
        local marks = marks_for(bufnr)

        assert.are.equal(2, #marks)
    end)

    it('highlights all keyword occurrences regardless of node type when comments_only is false', function()
        comment.setup({ comments_only = false })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'lua'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            '-- TODO: real comment',
            "local s = 'TODO: not a comment'",
        })

        scanner.scan(bufnr)
        local marks = marks_for(bufnr)

        assert.are.equal(2, #marks)
    end)
end)
