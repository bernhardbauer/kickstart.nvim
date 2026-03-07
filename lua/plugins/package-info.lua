return {
  {
    'vuki656/package-info.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = {
      -- Check `:help nvim_set_hl()` for more attributes.
      highlights = {
        up_to_date = { -- highlight for up to date dependency virtual text
          fg = '#3C4048',
        },
        outdated = { -- highlight for outdated dependency virtual text
          fg = '#d19a66',
        },
        invalid = { -- highlight for invalid dependency virtual text
          fg = '#ee4b2b',
        },
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = '|  ', -- Icon for up to date dependencies
          outdated = '|  ', -- Icon for outdated dependencies
          invalid = '|  ', -- Icon for invalid dependencies
        },
      },
      notifications = true, -- Whether to display notifications when running commands
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
      -- Can be `npm`, `yarn`, `pnpm` or `bun`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock`, `package-lock.json` or `bun.lock`. If none are found it will use the
      -- provided one, if nothing is provided it will use `npm`
      package_manager = 'npm',
    },
    keys = {
      { '<leader>rnu', '<cmd>lua require("package-info").update()<cr>', desc = '[U]pdate dependency', silent = true, noremap = true },
      { '<leader>rnd', '<cmd>lua require("package-info").delete()<cr>', desc = '[D]elete dependency', silent = true, noremap = true },
      { '<leader>rnc', '<cmd>lua require("package-info").change_version()<cr>', desc = '[C]hange dependency version', silent = true, noremap = true },
    },
  },
}
