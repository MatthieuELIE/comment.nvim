describe('comment.commands.todo_insert', function()
    local todo_insert = require('comment.commands.todo_insert')

    it('is registered as the :TodoInsert user command by setup()', function()
        require('comment').setup()
        local commands = vim.api.nvim_get_commands({})

        assert.is_not_nil(commands.TodoInsert)
    end)

    before_each(function()
        vim.cmd('enew!')
    end)

    it('inserts a new indented comment line below the cursor on confirm', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { '    local x = 1' })
        vim.bo.filetype = 'lua'
        vim.api.nvim_win_set_cursor(0, { 1, 4 })
        local original_input = vim.ui.input
        vim.ui.input = function(_, on_confirm)
            on_confirm('fix this')
        end

        todo_insert.run()
        vim.ui.input = original_input
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.are.equal(2, #lines)
        assert.are.equal('    local x = 1', lines[1])
        assert.are.equal('    -- TODO: fix this', lines[2])
    end)

    it('inserts nothing when the prompt is cancelled with Esc (callback receives nil)', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local x = 1' })
        vim.bo.filetype = 'lua'
        local original_input = vim.ui.input
        vim.ui.input = function(_, on_confirm)
            on_confirm(nil)
        end

        todo_insert.run()
        vim.ui.input = original_input
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.are.equal(1, #lines)
    end)

    it('inserts nothing when the prompt is confirmed with empty input ("")', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local x = 1' })
        vim.bo.filetype = 'lua'
        local original_input = vim.ui.input
        vim.ui.input = function(_, on_confirm)
            on_confirm('')
        end

        todo_insert.run()
        vim.ui.input = original_input
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.are.equal(1, #lines)
    end)

    it('inserts a NOTE/FIX/HACK comment when run(keyword) is called with a non-default keyword', function()
        for _, case in ipairs({
            { keyword = 'NOTE', expected = '    -- NOTE: fix this' },
            { keyword = 'FIX', expected = '    -- FIX: fix this' },
            { keyword = 'HACK', expected = '    -- HACK: fix this' },
        }) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { '    local x = 1' })
            vim.bo.filetype = 'lua'
            vim.api.nvim_win_set_cursor(0, { 1, 4 })
            local original_input = vim.ui.input
            vim.ui.input = function(_, on_confirm)
                on_confirm('fix this')
            end

            todo_insert.run(case.keyword)
            vim.ui.input = original_input
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal(2, #lines)
            assert.are.equal(case.expected, lines[2])
        end
    end)

    it('exposes todo/note/fix/hack wrappers that call run() with their keyword', function()
        for _, case in ipairs({
            { fn = todo_insert.todo, expected = '-- TODO: fix this' },
            { fn = todo_insert.note, expected = '-- NOTE: fix this' },
            { fn = todo_insert.fix, expected = '-- FIX: fix this' },
            { fn = todo_insert.hack, expected = '-- HACK: fix this' },
        }) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local x = 1' })
            vim.bo.filetype = 'lua'
            local original_input = vim.ui.input
            vim.ui.input = function(_, on_confirm)
                on_confirm('fix this')
            end

            case.fn()
            vim.ui.input = original_input
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal(2, #lines)
            assert.are.equal(case.expected, lines[2])
        end
    end)

    it('exposes require("comment").insert.{todo,note,fix,hack} without requiring setup()', function()
        package.loaded['comment'] = nil
        local comment = require('comment')

        assert.is_function(comment.insert.todo)
        assert.is_function(comment.insert.note)
        assert.is_function(comment.insert.fix)
        assert.is_function(comment.insert.hack)
    end)

    it('notifies instead of inserting when the filetype has no commentstring', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local x = 1' })
        vim.bo.filetype = 'lua'
        local original_get_option = vim.filetype.get_option
        vim.filetype.get_option = function()
            return ''
        end
        local original_notify = vim.notify
        local notified = false
        vim.notify = function()
            notified = true
        end
        local original_input = vim.ui.input
        vim.ui.input = function(_, on_confirm)
            on_confirm('fix this')
        end

        todo_insert.run()
        vim.ui.input = original_input
        vim.filetype.get_option = original_get_option
        vim.notify = original_notify
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.is_true(notified)
        assert.are.equal(1, #lines)
    end)
end)
