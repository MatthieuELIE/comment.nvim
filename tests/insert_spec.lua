describe('comment.insert.format', function()
    local insert = require('comment.insert')

    it('wraps keyword and text using a single-line commentstring', function()
        local result = insert.format('TODO', 'fix this', '-- %s')

        assert.are.equal('-- TODO: fix this', result)
    end)

    it('resolves the real lua commentstring via vim.filetype.get_option', function()
        local commentstring = vim.filetype.get_option('lua', 'commentstring')
        local result = insert.format('TODO', 'fix this', commentstring)

        assert.are.equal('-- TODO: fix this', result)
    end)

    it('handles two-sided commentstrings without dropping the closing delimiter', function()
        local c_result = insert.format('TODO', 'fix this', '/*%s*/')
        local html_result = insert.format('TODO', 'fix this', '<!--%s-->')

        assert.are.equal('/*TODO: fix this*/', c_result)
        assert.are.equal('<!--TODO: fix this-->', html_result)
    end)

    it('does not corrupt text containing a literal % character', function()
        local result = insert.format('TODO', '100% done, revisit', '-- %s')

        assert.are.equal('-- TODO: 100% done, revisit', result)
    end)

    it('returns nil for a missing or empty commentstring instead of erroring', function()
        local nil_result = insert.format('TODO', 'fix this', nil)
        local empty_result = insert.format('TODO', 'fix this', '')

        assert.is_nil(nil_result)
        assert.is_nil(empty_result)
    end)
end)
