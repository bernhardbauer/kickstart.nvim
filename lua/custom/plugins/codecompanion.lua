return {
  {
    'olimorris/codecompanion.nvim',
    opts = {
      display = {
        chat = {
          auto_scroll = true,
          start_in_insert_mode = false,
        },
      },
      adapters = {
        opts = {
          show_defaults = false,
        },
        qwen3 = function()
          return require('codecompanion.adapters').extend('ollama', {
            name = 'qwen3',
            schema = {
              model = {
                default = 'qwen3:8b',
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'qwen3',
        },
        inline = {
          adapter = 'qwen3',
        },
        cmd = {
          adapter = 'qwen3',
        },
      },
    },
    keys = {
      { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', desc = '[C]ompanion [C]hat' },
      { '<leader>ca', '<cmd>CodeCompanionActions<cr>', desc = '[C]ompanion [A]ctions', mode = { 'n', 'v' } },
      { '<leader>cv', '<cmd>CodeCompanionChat Add<cr>', desc = '[C]ompanion [V]isually selected to chat', mode = { 'v' } },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
