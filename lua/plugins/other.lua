return {
  {
    'rgroli/other.nvim',
    config = function()
      require('other-nvim').setup {
        mappings = {
          'angular',
        },
        rememberBuffers = false,
        hooks = {
          onFindOtherFiles = function(matches)
            if #matches <= 1 then
              return matches
            end
            vim.ui.select(matches, {
              prompt = 'Other Files',
              format_item = function(item)
                local label = vim.fn.fnamemodify(item.filename, ':t')
                return item.exists and label or label .. ' (new)'
              end,
            }, function(item)
              if item then
                local dir = vim.fn.fnamemodify(item.filename, ':h')
                if vim.fn.isdirectory(dir) == 0 then
                  vim.fn.mkdir(dir, 'p')
                end
                vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
              end
            end)
            return {}
          end,
        },
      }
    end,
    keys = {
      {
        '<leader>fa',
        function()
          -- Suppress the "No 'other' file found." notification
          local orig_notify = vim.notify
          vim.notify = function(msg, ...)
            if msg ~= "No 'other' file found." then
              orig_notify(msg, ...)
            end
          end
          vim.cmd 'Other'
          vim.notify = orig_notify
        end,
        desc = '[F]ind [A]lternative',
      },
    },
  },
}
