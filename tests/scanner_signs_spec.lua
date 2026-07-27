local scanner = require('comment.scanner')
local keywords = require('comment.keywords')
local config = require('comment.config')

local function get_marks(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, scanner.namespace, 0, -1, { details = true })
end

describe('comment.scanner signs', function()
    after_each(function()
        -- Reset to defaults so option state never leaks between tests.
        config.merge({})
    end)

    it('sets sign_text and sign_hl_group to the keyword default when no override is configured', function()
        config.merge({})
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
        -- Neovim right-pads a 1-cell sign_text to 2 cells on the extmark.
        assert.are.equal('T', vim.trim(marks[1][4].sign_text))
        assert.are.equal(keywords.keywords.TODO.hl_group, marks[1][4].sign_hl_group)
    end)

    it('gives NOTE, FIX, and HACK their own default sign letter and matching hl group', function()
        config.merge({})
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'NOTE: a', 'FIX: b', 'HACK: c' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)
        table.sort(marks, function(a, b)
            return a[2] < b[2]
        end)

        assert.are.equal(3, #marks)
        assert.are.equal('N', vim.trim(marks[1][4].sign_text))
        assert.are.equal(keywords.keywords.NOTE.hl_group, marks[1][4].sign_hl_group)
        assert.are.equal('F', vim.trim(marks[2][4].sign_text))
        assert.are.equal(keywords.keywords.FIX.hl_group, marks[2][4].sign_hl_group)
        assert.are.equal('H', vim.trim(marks[3][4].sign_text))
        assert.are.equal(keywords.keywords.HACK.hl_group, marks[3][4].sign_hl_group)
    end)

    it('uses a per-keyword sign override from config instead of the default letter', function()
        -- A 2-char override, so no Neovim padding to account for.
        config.merge({ signs = { TODO = 'TD' } })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
        assert.are.equal('TD', marks[1][4].sign_text)
    end)

    it('falls back to the default letter and warns once when an override is not 1-2 display cells', function()
        config.merge({ signs = { TODO = 'TOOLONG' } })
        local notified = {}
        local original_notify = vim.notify
        vim.notify = function(msg, level)
            table.insert(notified, { msg = msg, level = level })
        end

        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        local ok = pcall(scanner.scan, bufnr)
        vim.notify = original_notify
        local marks = get_marks(bufnr)

        assert.is_true(ok)
        assert.are.equal(1, #marks)
        assert.are.equal(keywords.keywords.TODO.sign, vim.trim(marks[1][4].sign_text))
        assert.are.equal(1, #notified)
        assert.are.equal(vim.log.levels.WARN, notified[1].level)
    end)

    it('ships default sign_text values that all respect the 1-2 display cell rendering constraint', function()
        for _, spec in pairs(keywords.keywords) do
            local width = vim.fn.strdisplaywidth(spec.sign)
            assert.is_true(width >= 1 and width <= 2)
        end
    end)

    it('falls back to the default sign when signs is a non-table value', function()
        config.merge({ signs = 0 })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this' })

        local ok = pcall(scanner.scan, bufnr)
        local marks = get_marks(bufnr)

        assert.is_true(ok)
        assert.are.equal(1, #marks)
        assert.are.equal(keywords.keywords.TODO.sign, vim.trim(marks[1][4].sign_text))
    end)

    it('only sets sign_text on the first match when two keywords share a line', function()
        config.merge({})
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this FIX: too' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        local with_sign = 0
        for _, mark in ipairs(marks) do
            if mark[4].sign_text ~= nil then
                with_sign = with_sign + 1
            end
        end

        assert.are.equal(2, #marks)
        assert.are.equal(1, with_sign)
    end)
end)
