local config = require('comment.config')
local keywords = require('comment.keywords')
local autocmd = require('comment.autocmd')
local search = require('comment.search')
local quickfix = require('comment.quickfix')
local todo_insert = require('comment.commands.todo_insert')
local telescope = require('comment.telescope')

local M = {}

-- ponytail: placeholder keyword list until EPIC-01's config.keywords lands;
-- swap for `config.options.keywords` once that story ships.
local DEFAULT_KEYWORDS = { 'TODO', 'FIXME', 'HACK', 'NOTE' }

--- Entry point. Merges `opts` over the defaults in `comment.config`, registers
--- the keyword highlight groups and the autocmds that keep highlights in sync
--- while editing, and registers user commands (e.g. `:TodoQuickFix`,
--- `:TodoInsert`). Safe to call with no arguments or a partial options table.
---@param opts table|nil
function M.setup(opts)
    config.merge(opts)
    keywords.setup_highlights()
    autocmd.setup()

    vim.api.nvim_create_user_command('TodoQuickFix', function()
        local _, raw_lines, err = search.run(DEFAULT_KEYWORDS)
        if err then
            vim.notify('comment.nvim: ' .. err, vim.log.levels.WARN)
        end
        quickfix.show(raw_lines)
    end, {})

    vim.api.nvim_create_user_command('TodoInsert', function()
        todo_insert.run()
    end, { desc = 'Prompt for todo text and insert it as a comment below the cursor' })

    vim.api.nvim_create_user_command('TodoTelescope', function()
        local _, raw_lines, err = search.run(DEFAULT_KEYWORDS)
        if err then
            vim.notify('comment.nvim: ' .. err, vim.log.levels.WARN)
        end
        telescope.show(raw_lines)
    end, {})
end

return M
