describe(':TodoTelescope command', function()
    before_each(function()
        require('comment').setup()
    end)

    it('is registered by setup()', function()
        local commands = vim.api.nvim_get_commands({})
        assert.is_not_nil(commands.TodoTelescope)
    end)

    -- Telescope is not a dev dependency of this repo, so `require('telescope')`
    -- genuinely fails here -- this exercises the real availability guard
    -- rather than a mock.
    it('reports Telescope unavailable via vim.notify(WARN) instead of erroring', function()
        local notified = {}
        local original_notify = vim.notify
        vim.notify = function(msg, level)
            notified[#notified + 1] = { msg = msg, level = level }
        end

        local ok = pcall(vim.cmd, 'TodoTelescope')

        vim.notify = original_notify

        assert.is_true(ok)

        local found = false
        for _, n in ipairs(notified) do
            if n.msg:find('Telescope') and n.level == vim.log.levels.WARN then
                found = true
            end
        end
        assert.is_true(found)
    end)
end)
