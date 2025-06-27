return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- 'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    { '<leader>dB', '<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>', desc = '[D]ebug [B]reakpoint Condition' },
    { '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<cr>', desc = '[D]ebug [B]reakpoint Toggle' },
    { '<leader>dc', '<cmd>lua require("dap").continue()<cr>', desc = '[D]ebug [C]ontinue/Run' },
    { '<leader>da', '<cmd>lua require("dap").continue({ before = get_args })<cr>', desc = 'Run with Args' },
    { '<leader>dC', '<cmd>lua require("dap").run_to_cursor()<cr>', desc = 'Run to Cursor' },
    { '<leader>dg', '<cmd>lua require("dap").goto_()<cr>', desc = 'Go to Line (No Execute)' },
    { '<leader>di', '<cmd>lua require("dap").step_into()<cr>', desc = 'Step Into' },
    { '<leader>dj', '<cmd>lua require("dap").down()<cr>', desc = 'Down' },
    { '<leader>dk', '<cmd>lua require("dap").up()<cr>', desc = 'Up' },
    { '<leader>dl', '<cmd>lua require("dap").run_last()<cr>', desc = 'Run Last' },
    { '<leader>do', '<cmd>lua require("dap").step_out()<cr>', desc = 'Step Out' },
    { '<leader>dO', '<cmd>lua require("dap").step_over()<cr>', desc = 'Step Over' },
    { '<leader>dP', '<cmd>lua require("dap").pause()<cr>', desc = 'Pause' },
    { '<leader>dr', '<cmd>lua require("dap").repl.toggle()<cr>', desc = 'Toggle REPL' },
    { '<leader>ds', '<cmd>lua require("dap").session()<cr>', desc = 'Session' },
    { '<leader>dt', '<cmd>lua require("dap").terminate()<cr>', desc = 'Terminate' },
    { '<leader>dw', '<cmd>lua require("dap.ui.widgets").hover()<cr>', desc = 'Widgets' },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    { '<leader>du', '<cmd>lua require("dapui").toggle()<cr>', desc = 'Debug: See last session result.' },
    { '<F5>', '<cmd>lua require("dap").continue()<cr>', desc = 'Debug: Start/Continue' },
    { '<F1>', '<cmd>lua require("dap").step_into()<cr>', desc = 'Debug: Step Into' },
    { '<F2>', '<cmd>lua require("dap").step_over()<cr>', desc = 'Debug: Step Over' },
    { '<F3>', '<cmd>lua require("dap").step_out()<cr>', desc = 'Debug: Step Out' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'js', 'coreclr' },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = { os.getenv 'HOME' .. '/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
      },
    }
  end,
}
