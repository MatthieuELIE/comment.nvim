local treesitter = require('comment.treesitter')

describe('comment.treesitter.is_comment', function()
    it('returns true for a position inside a comment node, when a parser is installed', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'lua'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '-- this is a comment', 'local x = 1' })

        local result = treesitter.is_comment(bufnr, 0, 5)

        assert.is_true(result)
    end)

    it('returns false for a position outside any comment node, when a parser is installed', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'lua'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '-- this is a comment', 'local x = 1' })

        local result = treesitter.is_comment(bufnr, 1, 0)

        assert.is_false(result)
    end)

    it('returns nil without erroring when no TreeSitter parser is installed for the filetype', function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[bufnr].filetype = 'a_filetype_with_no_treesitter_parser'
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        local ok, result = pcall(treesitter.is_comment, bufnr, 0, 0)

        assert.is_true(ok)
        assert.is_nil(result)
    end)
end)
