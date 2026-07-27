describe(':TodoQuickFix command', function()
    before_each(function()
        require('comment').setup()
    end)

    after_each(function()
        vim.cmd('cclose')
        vim.fn.setqflist({}, ' ', { title = '', lines = {} })
    end)

    it('is registered by setup()', function()
        local commands = vim.api.nvim_get_commands({})
        assert.is_not_nil(commands.TodoQuickFix)
    end)

    it('runs search.run() and displays results via quickfix.show(), replacing on repeat runs', function()
        vim.cmd('TodoQuickFix')
        local first_count = #vim.fn.getqflist()

        vim.cmd('TodoQuickFix')
        local second_count = #vim.fn.getqflist()

        assert.is_true(first_count > 0)

        -- Same repo, same keywords -> same match count both times. If the
        -- second run appended instead of replacing, this would double.
        assert.are.equal(first_count, second_count)
    end)
end)
