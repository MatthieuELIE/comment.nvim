local scanner = require('comment.scanner')
local keywords = require('comment.keywords')
local config = require('comment.config')

local function get_marks(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, scanner.namespace, 0, -1, { details = true })
end

describe('comment.scanner line_hl_group', function()
    after_each(function()
        -- Reset to defaults so option state never leaks between tests.
        config.merge({})
    end)

    it('sets no line_hl_group when the option is left at its default (off)', function()
        config.merge({})
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '-- TODO: fix this' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
        assert.are.equal(keywords.keywords.TODO.hl_group, marks[1][4].hl_group)
        assert.is_nil(marks[1][4].line_hl_group)
    end)

    it('sets line_hl_group to the matched keyword own line highlight group when enabled', function()
        config.merge({ line_hl_group = true })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '-- TODO: fix this' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        assert.are.equal(1, #marks)
        assert.are.equal(keywords.keywords.TODO.line_hl_group, marks[1][4].line_hl_group)
    end)

    it('gives each line its own matching keyword color, not a shared one', function()
        config.merge({ line_hl_group = true })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this', 'FIX: this too' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)
        table.sort(marks, function(a, b)
            return a[2] < b[2]
        end)

        assert.are.equal(2, #marks)
        assert.are.equal(keywords.keywords.TODO.line_hl_group, marks[1][4].line_hl_group)
        assert.are.equal(keywords.keywords.FIX.line_hl_group, marks[2][4].line_hl_group)
    end)

    it('only sets line_hl_group on the first match when two keywords share a line', function()
        config.merge({ line_hl_group = true })
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'TODO: fix this FIX too' })

        scanner.scan(bufnr)
        local marks = get_marks(bufnr)

        local with_line_hl = 0
        for _, mark in ipairs(marks) do
            if mark[4].line_hl_group ~= nil then
                with_line_hl = with_line_hl + 1
            end
        end

        assert.are.equal(2, #marks)
        assert.are.equal(1, with_line_hl)
    end)

    it('registers a distinct linked highlight group per keyword, not a reuse of hl_group', function()
        keywords.setup_highlights()

        assert.are_not.equal(keywords.keywords.TODO.hl_group, keywords.keywords.TODO.line_hl_group)
        local line_hl = vim.api.nvim_get_hl(0, { name = keywords.keywords.TODO.line_hl_group, link = true })
        assert.are.equal(keywords.keywords.TODO.hl_group, line_hl.link)
    end)
end)
