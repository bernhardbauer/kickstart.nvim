return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      dashboard = {
        sections = {
          { section = 'header' },
          { section = 'recent_files', cwd = true, limit = 8, padding = 1 },
          { section = 'startup' },
        },
      },
      input = {}, -- used by opencode.ask()
      picker = {
        hidden = true, -- show hidden files by default across all sources
      }, -- used by opencode.select()
      explorer = {
        replace_netrw = false, -- don't auto-open explorer on `nvim .`
      },
      indent = {},
      gitbrowse = {},
      lazygit = {},
      notifier = {},
    },
    keys = {
      {
        '<leader>gg',
        function()
          Snacks.lazygit.open()
        end,
        desc = 'Lazygit',
      },
      {
        '\\',
        function()
          Snacks.explorer.open()
        end,
        desc = 'Toggle Explorer',
      },
      {
        '<leader>xn',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Notification History',
      },
    },
  },
}
