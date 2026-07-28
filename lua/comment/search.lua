local M = {}

---@param keywords string[]
---@return table[]
---@return string[]
---@return string|nil
function M.run(keywords)
    keywords = keywords or {}
    if #keywords == 0 then
        return {}, {}, nil
    end

    -- --hidden so dotfiles-repo layouts (e.g. ~/dotfiles/.config/nvim/...)
    -- get searched too: ripgrep skips any dot-prefixed path component by
    -- default. -g '!.git' keeps out the one hidden dir nobody wants scanned.
    local cmd = { 'rg', '--vimgrep', '--hidden', '-g', '!.git' }
    for _, keyword in ipairs(keywords) do
        cmd[#cmd + 1] = '-e'
        cmd[#cmd + 1] = '\\b' .. keyword .. ':'
    end

    local ok, result = pcall(function()
        return vim.system(cmd, { text = true, cwd = vim.fn.getcwd() }):wait()
    end)

    if not ok then
        return {}, {}, 'ripgrep (rg) could not be run: ' .. tostring(result)
    end

    if result.code >= 2 then
        return {}, {}, 'ripgrep failed: ' .. (result.stderr ~= '' and result.stderr or ('exit code ' .. result.code))
    end

    local raw_lines = vim.split(result.stdout or '', '\n', { trimempty = true })

    local results = {}
    for _, line in ipairs(raw_lines) do
        local filename, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
        if filename then
            results[#results + 1] = {
                filename = filename,
                lnum = tonumber(lnum),
                col = tonumber(col),
                text = text,
            }
        end
    end

    return results, raw_lines, nil
end

return M
