local M = {}

---@param raw_lines string[]
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
