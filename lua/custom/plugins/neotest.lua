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
      { '<leader>tt', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', desc = '[T]est [T]File' },
      { '<leader>tw', "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>", desc = '[T]est [W]atch' },
      { '<leader>tt', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', desc = 'Run File (Neotest)' },
      { '<leader>tT', '<cmd>lua require("neotest").run.run(vim.uv.cwd())<cr>', desc = 'Run All Test Files (Neotest)' },
      { '<leader>tr', '<cmd>lua require("neotest").run.run()<cr>', desc = 'Run Nearest (Neotest)' },
      { '<leader>tl', '<cmd>lua require("neotest").run.run_last()<cr>', desc = 'Run Last (Neotest)' },
      { '<leader>ts', '<cmd>lua require("neotest").summary.toggle()<cr>', desc = 'Toggle Summary (Neotest)' },
      { '<leader>to', '<cmd>lua require("neotest").output.open({ enter = true, auto_close = true })<cr>', desc = 'Show Output (Neotest)' },
      { '<leader>tO', '<cmd>lua require("neotest").output_panel.toggle()<cr>', desc = 'Toggle Output Panel (Neotest)' },
      { '<leader>tS', '<cmd>lua require("neotest").run.stop()<cr>', desc = 'Stop (Neotest)' },
      { '<leader>tw', '<cmd>lua require("neotest").watch.toggle(vim.fn.expand("%"))<cr>', desc = 'Toggle Watch (Neotest)' },
      { '<leader>td', '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', desc = 'Debug Nearest' },
    },
  },
}
