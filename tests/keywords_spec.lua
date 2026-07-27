describe('comment.keywords', function()
    it('exposes TODO/FIX/HACK/NOTE with a highlight group name and color', function()
        local keywords = require('comment.keywords')

        assert.is_table(keywords.keywords.TODO)
        assert.is_table(keywords.keywords.FIX)
        assert.is_table(keywords.keywords.HACK)
        assert.is_table(keywords.keywords.NOTE)
        for _, spec in pairs(keywords.keywords) do
            assert.is_string(spec.hl_group)
            assert.is_string(spec.link)
        end
    end)

    it('registers each highlight group via nvim_set_hl without erroring, repeatedly', function()
        local keywords = require('comment.keywords')

        local first_ok = pcall(keywords.setup_highlights)
        -- Simulates a colorscheme reload re-triggering registration.
        local second_ok = pcall(keywords.setup_highlights)
        local todo_hl = vim.api.nvim_get_hl(0, { name = keywords.keywords.TODO.hl_group })

        assert.is_true(first_ok)
        assert.is_true(second_ok)
        assert.are.equal('DiagnosticInfo', todo_hl.link)
    end)
end)
