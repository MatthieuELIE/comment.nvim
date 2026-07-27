local search = require('comment.search')

--- Create an empty temp directory and return its path.
local function make_tmp_dir()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    return dir
end

--- Write `content` to `dir .. '/' .. name`.
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

    it('returns empty results without running ripgrep when keywords is empty', function()
        local results, raw_lines, err = search.run({})

        assert.are.same({}, results)
        assert.are.same({}, raw_lines)
        assert.is_nil(err)
    end)
end)
