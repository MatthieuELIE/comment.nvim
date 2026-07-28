local keywords = require('comment.keywords')
local config = require('comment.config')
local treesitter = require('comment.treesitter')

local M = {}

M.namespace = vim.api.nvim_create_namespace('comment_nvim_keywords')

local function is_valid_sign_text(text)
    if type(text) ~= 'string' then
        return false
    end
    local width = vim.fn.strdisplaywidth(text)
    return width >= 1 and width <= 2
end

---@param bufnr integer
function M.scan(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)

    local comments_only = config.options.comments_only
    local line_hl_group = config.options.line_hl_group

    local sign_overrides = config.options.signs
    if type(sign_overrides) ~= 'table' then
        sign_overrides = {}
    end

    local patterns = {}
    for keyword, spec in pairs(keywords.keywords) do
        local sign_text = sign_overrides[keyword]
        if sign_text ~= nil then
            if not is_valid_sign_text(sign_text) then
                vim.notify(
                    string.format(
                        'comment.nvim: invalid sign for %s (%s), must be 1-2 display cells; using default %q',
                        keyword,
                        vim.inspect(sign_text),
                        spec.sign
                    ),
                    vim.log.levels.WARN
                )
                sign_text = spec.sign
            end
        else
            sign_text = spec.sign
        end

        patterns[#patterns + 1] =
            { pattern = '%f[%w]' .. vim.pesc(keyword) .. '%f[%W]', spec = spec, sign_text = sign_text }
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for row, line in ipairs(lines) do
        local line_hl_done = false
        local sign_done = false

        for _, kp in ipairs(patterns) do
            local pattern, spec = kp.pattern, kp.spec
            local search_from = 1
            while true do
                local start_col, end_col = line:find(pattern, search_from)
                if not start_col then
                    break
                end

                local is_marker = line:sub(end_col + 1, end_col + 1) == ':'
                local is_comment = not comments_only or treesitter.is_comment(bufnr, row - 1, start_col - 1) ~= false

                if is_marker and is_comment then
                    local extmark_opts = {
                        end_col = end_col,
                        hl_group = spec.hl_group,
                    }

                    if line_hl_group and not line_hl_done then
                        extmark_opts.line_hl_group = spec.line_hl_group
                        line_hl_done = true
                    end

                    if not sign_done then
                        extmark_opts.sign_text = kp.sign_text
                        extmark_opts.sign_hl_group = spec.hl_group
                        sign_done = true
                    end

                    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, row - 1, start_col - 1, extmark_opts)
                end

                search_from = end_col + 1
            end
        end
    end
end

return M
