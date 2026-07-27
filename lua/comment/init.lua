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

-- `<leader>t?` -> single-keyword mapping registered when `keymaps = true`.
local KEYWORD_KEYMAPS = {
    { lhs = '<leader>tt', keyword = 'TODO' },
    { lhs = '<leader>tn', keyword = 'NOTE' },
    { lhs = '<leader>tf', keyword = 'FIX' },
    { lhs = '<leader>th', keyword = 'HACK' },
}

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
--- Public so users who leave `keymaps = false` still have a supported way to
--- bind their own keys, e.g. `vim.keymap.set('n', '<leader>tt', function()
--- require('comment').todo_quickfix({ 'TODO' }) end)`.
---@param todo_keywords string[] keywords to search for, e.g. { 'TODO' }
---@param title string|nil optional quickfix list title
function M.todo_quickfix(todo_keywords, title)
    quickfix.show(search_and_notify(todo_keywords), title and { title = title } or nil)
end

--- Entry point: merges `opts` over defaults, registers highlight groups,
--- autocmds, and user commands (`:TodoQuickFix`, `:TodoInsert`,
--- `:TodoTelescope`). With `keymaps = true`, also registers `<leader>tt`
--- (TODO), `<leader>tn` (NOTE), `<leader>tf` (FIX), `<leader>th` (HACK).
--- Safe to call with no arguments.
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

    for _, map in ipairs(KEYWORD_KEYMAPS) do
        pcall(vim.keymap.del, 'n', map.lhs)
    end
    if config.options.keymaps then
        for _, map in ipairs(KEYWORD_KEYMAPS) do
            vim.keymap.set('n', map.lhs, function()
                M.todo_quickfix({ map.keyword }, map.keyword .. ' search')
            end, { desc = 'comment.nvim: quickfix filtered to ' .. map.keyword })
        end
    end
end

return M
