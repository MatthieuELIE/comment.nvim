local quickfix = require('comment.quickfix')

local function qf_window_open()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            return true
        end
    end
    return false
end

describe('comment.quickfix', function()
    after_each(function()
        vim.cmd('cclose')
        vim.fn.setqflist({}, ' ', { title = '', lines = {} })
    end)

    it('populates one entry per raw vimgrep line and opens the window', function()
        local raw_lines = {
            'fixture.lua:1:5:-- TODO: one',
            'fixture.lua:3:5:-- TODO: two',
        }

        quickfix.show(raw_lines, { title = 'My search' })

        local qf = vim.fn.getqflist()
        assert.are.equal(2, #qf)
        assert.are.equal(1, qf[1].lnum)
        assert.are.equal(3, qf[2].lnum)
        assert.are.equal('My search', vim.fn.getqflist({ title = 1 }).title)
        assert.is_true(qf_window_open())
    end)

    it('replaces rather than appends on a second call', function()
        quickfix.show({ 'fixture.lua:1:5:-- TODO: one' })
        quickfix.show({ 'fixture.lua:2:5:-- TODO: two' })

        local qf = vim.fn.getqflist()
        assert.are.equal(1, #qf)
        assert.are.equal(2, qf[1].lnum)
    end)

    it('sets an empty list and does not open the window when there are no results', function()
        quickfix.show({})

        assert.are.equal(0, #vim.fn.getqflist())
        assert.is_false(qf_window_open())
    end)
end)
