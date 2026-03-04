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
          { section = 'keys', gap = 1, padding = 1 },
          { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          {
            pane = 2,
            icon = ' ',
            title = 'Git Status',
            section = 'terminal',
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = 'git status --short --branch --renames',
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = 'startup' },
        },
      },
      input = {}, -- used by opencode.ask()
      picker = {
        hidden = true, -- show hidden files by default across all sources
      }, -- used by opencode.select()
      explorer = {}, -- used by opencode.select()
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
