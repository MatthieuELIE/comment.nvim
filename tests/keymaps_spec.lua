local LEADER_MAPS = { '<leader>tt', '<leader>tn', '<leader>tf', '<leader>th' }

local function unmap_all()
    for _, lhs in ipairs(LEADER_MAPS) do
        pcall(vim.keymap.del, 'n', lhs)
    end
end

describe('opt-in keyword-filtered keymaps', function()
    after_each(function()
        unmap_all()
    end)

    it('registers none of the four maps when keymaps is left at its default (false)', function()
        require('comment').setup({})

        for _, lhs in ipairs(LEADER_MAPS) do
            assert.are.equal('', vim.fn.maparg(lhs, 'n'))
        end
    end)

    it('registers none of the four maps when keymaps = false is explicit', function()
        require('comment').setup({ keymaps = false })

        for _, lhs in ipairs(LEADER_MAPS) do
            assert.are.equal('', vim.fn.maparg(lhs, 'n'))
        end
    end)

    it('registers all four maps when keymaps = true', function()
        require('comment').setup({ keymaps = true })

        for _, lhs in ipairs(LEADER_MAPS) do
            assert.are_not.equal('', vim.fn.maparg(lhs, 'n'))
        end
    end)

    it('binds each map to its own keyword via M.todo_quickfix, without triggering ripgrep', function()
        -- Stub the public entry point so invoking the mapped callback directly
        -- (no feedkeys/ripgrep involved) only proves keyword routing.
        local comment = require('comment')
        local original = comment.todo_quickfix
        local captured = {}
        comment.todo_quickfix = function(kws, title)
            captured[#captured + 1] = { keywords = kws, title = title }
        end

        comment.setup({ keymaps = true })
        for _, lhs in ipairs(LEADER_MAPS) do
            vim.fn.maparg(lhs, 'n', false, true).callback()
        end

        comment.todo_quickfix = original

        assert.are.same({ 'TODO' }, captured[1].keywords)
        assert.are.same({ 'NOTE' }, captured[2].keywords)
        assert.are.same({ 'FIX' }, captured[3].keywords)
        assert.are.same({ 'HACK' }, captured[4].keywords)
    end)
end)
