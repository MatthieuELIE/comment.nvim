local search = require('comment.search')

local function make_tmp_dir()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    return dir
end

local function write_file(dir, name, content)
    local path = dir .. '/' .. name
    local file = assert(io.open(path, 'w'))
    file:write(content)
    file:close()
    return path
end

describe('comment.search', function()
    local original_cwd

    before_each(function()
        original_cwd = vim.fn.getcwd()
    end)

    after_each(function()
        vim.fn.chdir(original_cwd)
    end)

    it('returns structured results and raw vimgrep lines when a keyword matches', function()
        local dir = make_tmp_dir()
        write_file(dir, 'fixture.lua', 'local x = 1 -- TODO: fix this\n')
        vim.fn.chdir(dir)

        local results, raw_lines, err = search.run({ 'TODO' })

        assert.is_nil(err)
        assert.are.equal(1, #results)
        assert.are.equal('fixture.lua', results[1].filename)
        assert.are.equal(1, results[1].lnum)
        assert.is_true(results[1].col > 0)
        assert.is_not_nil(results[1].text:find('TODO'))
        assert.are.equal(1, #raw_lines)
        assert.is_not_nil(raw_lines[1]:find('fixture%.lua:1:'))
    end)

    it('does not match a bare keyword without a marker colon', function()
        local dir = make_tmp_dir()
        write_file(dir, 'fixture.lua', 'local x = 1 -- this TODO thing needs work\n')
        vim.fn.chdir(dir)

        local results, raw_lines, err = search.run({ 'TODO' })

        assert.is_nil(err)
        assert.are.same({}, results)
        assert.are.same({}, raw_lines)
    end)

    it('returns empty results with no error when ripgrep exits 1 (no matches)', function()
        local dir = make_tmp_dir()
        write_file(dir, 'fixture.lua', 'local x = 1\n')
        vim.fn.chdir(dir)

        local results, raw_lines, err = search.run({ 'TODO' })

        assert.are.same({}, results)
        assert.are.same({}, raw_lines)
        assert.is_nil(err)
    end)

    it('returns empty results and a message when ripgrep is not on PATH', function()
        local original_path = vim.env.PATH
        vim.env.PATH = '/nonexistent-comment-nvim-test-path'

        local results, raw_lines, err = search.run({ 'TODO' })

        vim.env.PATH = original_path

        assert.are.same({}, results)
        assert.are.same({}, raw_lines)
        assert.is_not_nil(err)
    end)

    it('matches a fixture nested under a dot-prefixed directory (dotfiles repo layout)', function()
        local dir = make_tmp_dir()
        vim.fn.mkdir(dir .. '/.config/nvim/lua', 'p')
        write_file(dir, '.config/nvim/lua/fixture.lua', '-- TODO: pin plugin versions\n')
        vim.fn.chdir(dir)

        local results, raw_lines, err = search.run({ 'TODO' })

        assert.is_nil(err)
        assert.are.equal(1, #results)
        assert.are.equal('.config/nvim/lua/fixture.lua', results[1].filename)
        assert.are.equal(1, #raw_lines)
    end)

    it('still excludes .git even with hidden files searched', function()
        local dir = make_tmp_dir()
        vim.fn.mkdir(dir .. '/.git', 'p')
        write_file(dir, '.git/fixture.lua', '-- TODO: should never surface\n')
        write_file(dir, 'fixture.lua', '-- TODO: real one\n')
        vim.fn.chdir(dir)

        local results, _, err = search.run({ 'TODO' })

        assert.is_nil(err)
        assert.are.equal(1, #results)
        assert.are.equal('fixture.lua', results[1].filename)
    end)

    it('returns empty results without running ripgrep when keywords is empty', function()
        local results, raw_lines, err = search.run({})

        assert.are.same({}, results)
        assert.are.same({}, raw_lines)
        assert.is_nil(err)
    end)
end)
