describe('comment.config comments_only', function()
    it('defaults to false when no comments_only option is passed to setup()', function()
        local comment = require('comment')
        local config = require('comment.config')

        comment.setup()

        assert.is_false(config.options.comments_only)
    end)

    it('reflects true when setup({ comments_only = true }) is called', function()
        local comment = require('comment')
        local config = require('comment.config')

        comment.setup({ comments_only = true })

        assert.is_true(config.options.comments_only)
    end)
end)
