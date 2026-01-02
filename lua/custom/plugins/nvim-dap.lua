local dotnet_adapter = {
  type = 'executable',
  -- command = vim.fn.stdpath 'data' .. '/mason/bin/netcoredbg',
  command = os.getenv 'HOME' .. '/git/netcoredbg/build/src/netcoredbg',
  args = { '--interpreter=vscode' },
}

local dotnet_configuration = {
  {
    type = 'coreclr',
    name = 'launch - netcoredbg',
    request = 'launch',
    program = function()
      return require('configs.nvim-dap-dotnet').build_dll_path()
    end,
    stopAtEntry = true, -- required, otherwise the DAP breaks...
  },
}

local close_non_dap_ui = function()
  require('neo-tree.command').execute { action = 'close' }
  require('overseer').close()
end

local toggle_dap_ui = function()
  close_non_dap_ui()
  require('dapui').toggle { reset = true }
end

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      { '<leader>d', nil, desc = '[D]ebug' },
      { '<leader>dB', '<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>', desc = '[B]reakpoint Condition' },
      { '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<cr>', desc = '[B]reakpoint Toggle' },
      { '<leader>dc', '<cmd>lua require("dap").continue()<cr>', desc = '[C]ontinue/Run' },
      { '<leader>da', '<cmd>lua require("dap").continue({ before = get_args })<cr>', desc = 'Continue/Run with [A]rgs' },
      { '<leader>dC', '<cmd>lua require("dap").run_to_cursor()<cr>', desc = 'Run to [C]ursor' },
      { '<leader>dg', '<cmd>lua require("dap").goto_()<cr>', desc = '[G]o to Line (No Execute)' },
      { '<leader>dj', '<cmd>lua require("dap").down()<cr>', desc = 'Down' },
      { '<leader>dk', '<cmd>lua require("dap").up()<cr>', desc = 'Up' },
      { '<leader>dl', '<cmd>lua require("dap").run_last()<cr>', desc = 'Run [L]ast' },
      { '<leader>dP', '<cmd>lua require("dap").pause()<cr>', desc = '[P]ause' },
      { '<leader>dr', '<cmd>lua require("dap").repl.toggle()<cr>', desc = 'Toggle [R]EPL' },
      { '<leader>ds', '<cmd>lua require("dap").session()<cr>', desc = '[S]ession' },
      { '<leader>dt', '<cmd>lua require("dap").terminate()<cr>', desc = '[T]erminate' },
      { '<leader>dw', '<cmd>lua require("dap.ui.widgets").hover()<cr>', desc = '[W]idgets' },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<leader>du', toggle_dap_ui, desc = 'DAP [U]I: See last session result.' },
      -- TODO map to arrow keys
      { '<leader><Right>', '<cmd>lua require("dap").step_into()<cr>', desc = 'Debug: Step Into' },
      { '<leader><Down>', '<cmd>lua require("dap").step_over()<cr>', desc = 'Debug: Step Over' },
      { '<leader><Left>', '<cmd>lua require("dap").step_out()<cr>', desc = 'Debug: Step Out' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dapui_virtual_text = require 'nvim-dap-virtual-text'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,
        handlers = {},
        ensure_installed = { 'js', 'coreclr' },
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup()
      dapui_virtual_text.setup()

      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }

      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      -- Auto open dap ui and close other ui elements
      dap.listeners.after.event_initialized['dapui_config'] = function()
        close_non_dap_ui()
        require('dapui').open { reset = true }
      end
      -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

      dap.adapters.coreclr = dotnet_adapter -- unit test debugging
      dap.adapters.netcoredbg = dotnet_adapter -- normal debugging
      dap.configurations.cs = dotnet_configuration

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
  },
}
