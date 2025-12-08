-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal' },
    { '<leader>xb', ':Neotree buffers<CR>', desc = 'NeoTree show buffers', silent = true },
    { '<leader>hc', ':Neotree float git_status<CR>', desc = 'NeoTree show all changed files', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['<space>'] = 'none',
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
