describe(':TodoTelescope command', function()
    before_each(function()
        require('comment').setup()
    end)

    it('is registered by setup()', function()
        local commands = vim.api.nvim_get_commands({})
        assert.is_not_nil(commands.TodoTelescope)
    end)

    it('reports Telescope unavailable via vim.notify(WARN) instead of erroring', function()
        local notified = {}
        local original_notify = vim.notify
        vim.notify = function(msg, level)
            notified[#notified + 1] = { msg = msg, level = level }
        end

        local ok = pcall(vim.cmd, 'TodoTelescope')

        vim.notify = original_notify

        assert.is_true(ok)

        local found = false
        for _, n in ipairs(notified) do
            if n.msg:find('Telescope') and n.level == vim.log.levels.WARN then
                found = true
            end
        end
        assert.is_true(found)
    end)

    it('builds a picker from raw vimgrep lines using the expected finder/previewer/sorter', function()
        local original = {
            ['telescope'] = package.loaded['telescope'],
            ['telescope.config'] = package.loaded['telescope.config'],
            ['telescope.finders'] = package.loaded['telescope.finders'],
            ['telescope.make_entry'] = package.loaded['telescope.make_entry'],
            ['telescope.pickers'] = package.loaded['telescope.pickers'],
        }

        local finder_stub = { is_finder_stub = true }
        local entry_maker_stub = function() end
        local previewer_stub = { is_previewer_stub = true }
        local sorter_stub = { is_sorter_stub = true }
        local picker_stub = { find = function() end }

        local new_table_args, gen_from_vimgrep_called, pickers_new_args

        package.loaded['telescope'] = {}
        package.loaded['telescope.config'] = {
            values = {
                grep_previewer = function()
                    return previewer_stub
                end,
                generic_sorter = function()
                    return sorter_stub
                end,
            },
        }
        package.loaded['telescope.finders'] = {
            new_table = function(opts)
                new_table_args = opts
                return finder_stub
            end,
        }
        package.loaded['telescope.make_entry'] = {
            gen_from_vimgrep = function()
                gen_from_vimgrep_called = true
                return entry_maker_stub
            end,
        }
        package.loaded['telescope.pickers'] = {
            new = function(_, opts)
                pickers_new_args = opts
                return picker_stub
            end,
        }

        local telescope = require('comment.telescope')
        telescope.show({ 'fixture.lua:1:5:-- TODO: one' })

        package.loaded['telescope'] = original['telescope']
        package.loaded['telescope.config'] = original['telescope.config']
        package.loaded['telescope.finders'] = original['telescope.finders']
        package.loaded['telescope.make_entry'] = original['telescope.make_entry']
        package.loaded['telescope.pickers'] = original['telescope.pickers']

        assert.is_true(gen_from_vimgrep_called)
        assert.are.same({ 'fixture.lua:1:5:-- TODO: one' }, new_table_args.results)
        assert.are.equal(entry_maker_stub, new_table_args.entry_maker)
        assert.are.equal('Todos', pickers_new_args.prompt_title)
        assert.are.equal(finder_stub, pickers_new_args.finder)
        assert.are.equal(previewer_stub, pickers_new_args.previewer)
        assert.are.equal(sorter_stub, pickers_new_args.sorter)
    end)
end)
