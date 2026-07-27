local config = require('comment.config')
local keywords = require('comment.keywords')
local autocmd = require('comment.autocmd')
local search = require('comment.search')
local quickfix = require('comment.quickfix')
local todo_insert = require('comment.commands.todo_insert')
local telescope = require('comment.telescope')

local M = {}

-- Reuse keywords.lua's table as the single source of truth, so search
-- (:TodoQuickFix, :TodoTelescope) and highlighting never drift apart.
local DEFAULT_KEYWORDS = vim.tbl_keys(keywords.keywords)

--- Runs `search.run()` and notifies on a real error (ripgrep exit code >= 2;
--- "no matches" is not an error). Shared by `:TodoQuickFix`, `:TodoTelescope`,
--- and `M.todo_quickfix()` so the triplet isn't duplicated per callsite.
---@param search_keywords string[]
---@return string[] raw_lines
local function search_and_notify(search_keywords)
    local _, raw_lines, err = search.run(search_keywords)
    if err then
        vim.notify('comment.nvim: ' .. err, vim.log.levels.WARN)
    end
    return raw_lines
end

--- Search for `keywords` and display the results in the quickfix list.
--- Public so users can bind their own keys, e.g. `vim.keymap.set('n',
--- '<leader>tt', function() require('comment').todo_quickfix({ 'TODO' }) end)`.
---@param todo_keywords string[] keywords to search for, e.g. { 'TODO' }
---@param title string|nil optional quickfix list title
function M.todo_quickfix(todo_keywords, title)
    quickfix.show(search_and_notify(todo_keywords), title and { title = title } or nil)
end

--- Public per-keyword comment-insertion functions, e.g.
--- `vim.keymap.set('n', '<leader>tn', require('comment').insert.note)`.
--- No default keymap is bound for any of them. Implementation lives in
--- `comment.commands.todo_insert`; this table is just the public surface.
M.insert = {
    todo = todo_insert.todo,
    note = todo_insert.note,
    fix = todo_insert.fix,
    hack = todo_insert.hack,
}

--- Entry point: merges `opts` over defaults, registers highlight groups,
--- autocmds, and user commands (`:TodoQuickFix`, `:TodoInsert`,
--- `:TodoTelescope`). Safe to call with no arguments.
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
