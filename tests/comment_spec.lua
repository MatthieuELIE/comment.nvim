describe('comment.nvim bootstrap', function()
    it('setup() merges user options over the defaults without erroring', function()
        local comment = require('comment')

        local ok_no_args = pcall(comment.setup)
        local ok_partial_opts, err = pcall(comment.setup, { some_option = 'value' })
        local merged = require('comment.config').options

        assert.is_true(ok_no_args)
        assert.is_true(ok_partial_opts, err)
        assert.are.equal('value', merged.some_option)
    end)

    it('plugin/comment.lua sets a load guard and a second dofile is a no-op', function()
        vim.g.loaded_comment = nil

        dofile('plugin/comment.lua')

        assert.are.equal(1, vim.g.loaded_comment)

        vim.g.loaded_comment = 'sentinel'
        dofile('plugin/comment.lua')

        assert.are.equal('sentinel', vim.g.loaded_comment)
    end)
end)
