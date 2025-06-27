return {
  {
    'nvim-neotest/neotest',
    -- ft = { 'cs', 'typescript', 'javascript' },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'mfussenegger/nvim-dap',
      'nvim-neotest/neotest-jest',
      'Issafalcon/neotest-dotnet',
    },
    opts = function()
      return {
        discovery = {
          enabled = false,
        },
        adapters = {
          require 'neotest-dotnet' {
            dap = {
              -- Extra arguments for nvim-dap configuration
              -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
              args = { justMyCode = false },
              adapter_name = 'netcoredbg',
            },
          },
          require 'neotest-jest' {
            -- jestCommand = require('neotest-jest.jest-util').getJestCommand(vim.fn.expand '%:p:h') .. ' --runInBand --detectOpenHandles --forceExit',
            -- jestCommand = 'npm test --',
            jest_test_discovery = false,
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          },
        },
        log_level = vim.log.levels.DEBUG, -- Set the log level
      }
    end,
    keys = {
      { '<leader>tr', '<cmd>lua require("neotest").run.run()<cr>', desc = '[R]un Nearest' },
      { '<leader>tf', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', desc = 'Run Current [F]ile' },
      { '<leader>tA', '<cmd>lua require("neotest").run.run(vim.uv.cwd())<cr>', desc = 'Run [A]ll Test Files' },
      { '<leader>tl', '<cmd>lua require("neotest").run.run_last()<cr>', desc = 'Run [L]ast' },
      { '<leader>ts', '<cmd>lua require("neotest").summary.toggle()<cr>', desc = 'Toggle [S]ummary' },
      { '<leader>to', '<cmd>lua require("neotest").output.open({ enter = true, auto_close = true })<cr>', desc = 'Show [O]utput' },
      { '<leader>tO', '<cmd>lua require("neotest").output_panel.toggle()<cr>', desc = 'Toggle [O]utput Panel' },
      { '<leader>tS', '<cmd>lua require("neotest").run.stop()<cr>', desc = '[S]top' },
      { '<leader>tw', '<cmd>lua require("neotest").watch.toggle(vim.fn.expand("%"))<cr>', desc = '[W]atch Toggle' },
      { '<leader>td', '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', desc = '[D]ebug Nearest' },
    },
  },
}
