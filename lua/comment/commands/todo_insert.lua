local insert = require('comment.insert')

local M = {}

---@param keyword string|nil
function M.run(keyword)
    keyword = keyword or 'TODO'
    local prompt = ('%s: '):format(keyword:sub(1, 1) .. keyword:sub(2):lower())

    vim.ui.input({ prompt = prompt }, function(text)
        if text == nil or text == '' then
            return
        end

        local filetype = vim.bo.filetype
        local commentstring = vim.filetype.get_option(filetype, 'commentstring')
        local comment = insert.format(keyword, text, commentstring)

        if comment == nil then
            vim.notify(
                ("comment.nvim: no commentstring for filetype '%s', todo not inserted"):format(filetype),
                vim.log.levels.WARN
            )
            return
        end

        local row = vim.api.nvim_win_get_cursor(0)[1]
        local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
        local indent = current_line:match('^%s*')

        vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. comment })
    end)
end

function M.todo()
    M.run('TODO')
end

function M.note()
    M.run('NOTE')
end

function M.fix()
    M.run('FIX')
end

function M.hack()
    M.run('HACK')
end

return M
