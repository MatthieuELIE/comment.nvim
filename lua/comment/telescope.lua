local M = {}

--- Open a Telescope picker over todo occurrences.
---
--- Takes the raw `rg --vimgrep` lines produced by `comment.search.run()` and
--- feeds them straight to `telescope.make_entry.gen_from_vimgrep`, which
--- parses them into entries with file/line/column already set -- no custom
--- entry maker and no custom select action needed, Telescope's own default
--- mapping opens the file at the right position.
---
--- Availability guard: if Telescope isn't installed, notifies at WARN level
--- and returns instead of erroring cryptically.
---@param raw_lines string[] raw `rg --vimgrep` output lines, as returned by
--- `comment.search.run()`'s second return value
function M.show(raw_lines)
    local ok = pcall(require, 'telescope')
    if not ok then
        vim.notify('comment.nvim: Telescope is not installed', vim.log.levels.WARN)
        return
    end

    local conf = require('telescope.config').values
    local finders = require('telescope.finders')
    local make_entry = require('telescope.make_entry')
    local pickers = require('telescope.pickers')

    pickers
        .new({}, {
            prompt_title = 'Todos',
            finder = finders.new_table({
                results = raw_lines,
                entry_maker = make_entry.gen_from_vimgrep({}),
            }),
            previewer = conf.grep_previewer({}),
            sorter = conf.generic_sorter({}),
        })
        :find()
end

return M
