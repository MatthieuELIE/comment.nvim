local M = {}

--- Run ripgrep over the current working directory, searching for the given
--- keywords, and return both a structured result table and the raw
--- `--vimgrep` lines ripgrep produced. The raw lines are what
--- `comment.quickfix` feeds straight into `setqflist`'s `efm` parsing, and
--- are also the exact format Telescope's `make_entry.gen_from_vimgrep`
--- expects.
---
--- Synchronous by design (`vim.system():wait()`): keeps the signature simple
--- for both quickfix and Telescope consumers. Revisit only if a benchmark on
--- a large repository shows a measurable UI stall.
---@param keywords string[] keywords to search for, e.g. { 'TODO', 'FIXME' }
---@return table[] results one entry per match: { filename, lnum, col, text }
---@return string[] raw_lines raw `rg --vimgrep` output lines
---@return string|nil err set when the search could not run (e.g. no `rg` on PATH); nil on
--- success, including "no matches"
function M.run(keywords)
    keywords = keywords or {}
    if #keywords == 0 then
        return {}, {}, nil
    end

    local cmd = { 'rg', '--vimgrep' }
    for _, keyword in ipairs(keywords) do
        cmd[#cmd + 1] = '-e'
        cmd[#cmd + 1] = keyword
    end

    -- No path argument: `cwd` below makes ripgrep search "." implicitly,
    -- which keeps result paths relative (`fixture.lua`, not an absolute
    -- path) — the form quickfix/Telescope both expect.
    local ok, result = pcall(function()
        return vim.system(cmd, { text = true, cwd = vim.fn.getcwd() }):wait()
    end)

    if not ok then
        -- Most likely `rg` isn't on PATH; vim.system throws synchronously on spawn failure.
        return {}, {}, 'ripgrep (rg) could not be run: ' .. tostring(result)
    end

    -- Exit code 1 means "no matches" — not an error. Only >= 2 is a real failure.
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
