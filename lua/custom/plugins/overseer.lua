return {
  {
    'stevearc/overseer.nvim',
    opts = {},
    config = function()
      require('overseer').setup {
        templates = { 'builtin', 'user.dotnet_run' },
        task_list = {
          bindings = {
            ['<C-h>'] = false,
            ['<C-j>'] = false,
            ['<C-k>'] = false,
            ['<C-l>'] = false,
          },
        },
      }

      -- Make Overseer windows non-editable and prevent buffer switching
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'OverseerList',
        callback = function()
          vim.bo.modifiable = false
          vim.bo.readonly = true
          vim.bo.buftype = 'nofile'
          -- Prevent switching buffers in this window (Neovim 0.10+)
          vim.wo.winfixbuf = true
        end,
      })
    end,
    keys = {
      { '<leader>rv', '<cmd>OverseerToggle<cr>', desc = '[R]un [V]iew' },
      { '<leader>ra', '<cmd>OverseerRun<cr>', desc = '[R]un [A]ny' },
      { '<leader>rt', '<cmd>OverseerTaskAction<cr>', desc = '[R]un [T]ask' },
      { '<leader>rq', '<cmd>OverseerQuickAction<cr>', desc = '[R]un [Q]uick Action recent task' },
      { '<leader>ri', '<cmd>OverseerInfo<cr>', desc = '[R]und [I]nfo' },
      { '<leader>rb', '<cmd>OverseerBuild<cr>', desc = '[R]un [B]uilder' },
      { '<leader>rc', '<cmd>OverseerClearCache<cr>', desc = '[R]un [C]lear cache' },
    },
  },
}
