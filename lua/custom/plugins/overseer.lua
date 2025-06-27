return {
  {
    'stevearc/overseer.nvim',
    opts = {},
    config = function()
      require('overseer').setup()
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
