local config = require('comment.config')
local keywords = require('comment.keywords')
local autocmd = require('comment.autocmd')
local search = require('comment.search')
local quickfix = require('comment.quickfix')
local todo_insert = require('comment.commands.todo_insert')
local telescope = require('comment.telescope')

local M = {}

local DEFAULT_KEYWORDS = vim.tbl_keys(keywords.keywords)

---@param search_keywords string[]
---@return string[]
local function search_and_notify(search_keywords)
    local _, raw_lines, err = search.run(search_keywords)
    if err then
        vim.notify('comment.nvim: ' .. err, vim.log.levels.WARN)
    end
    return raw_lines
end

---@param todo_keywords string[]
---@param title string|nil
function M.todo_quickfix(todo_keywords, title)
    quickfix.show(search_and_notify(todo_keywords), title and { title = title } or nil)
end

M.insert = {
    todo = todo_insert.todo,
    note = todo_insert.note,
    fix = todo_insert.fix,
    hack = todo_insert.hack,
}

---@param opts table|nil
function M.setup(opts)
    config.merge(opts)
    keywords.setup_highlights()
    autocmd.setup()

    vim.api.nvim_create_user_command('TodoQuickFix', function()
        M.todo_quickfix(DEFAULT_KEYWORDS)
    end, {})

    vim.api.nvim_create_user_command('TodoInsert', function()
        todo_insert.run()
    end, { desc = 'Prompt for todo text and insert it as a comment below the cursor' })

    vim.api.nvim_create_user_command('TodoTelescope', function()
        telescope.show(search_and_notify(DEFAULT_KEYWORDS))
    end, {})
end

return M
