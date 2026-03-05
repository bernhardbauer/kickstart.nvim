local oc = function(method, ...)
  local args = { ... }
  return function()
    return require('opencode')[method](unpack(args))
  end
end

return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*', -- Latest stable release
    dependencies = {
      {
        -- `snacks.nvim` integration is recommended, but optional
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        'folke/snacks.nvim',
        optional = true,
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...)
                return require('opencode').snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ['<leader>ca'] = { 'opencode_send', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
    },
    init = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any; goto definition on the type or field for details
        lsp = { enabled = true },
      }

      vim.o.autoread = true -- Required for `opts.events.reload`
    end,
    keys = {
      { '<leader>c', nil, desc = 'AI / OpenCode' },
      { '<leader>ca', oc('ask', '@this: ', { submit = true }), desc = 'Ask opencode…', mode = { 'n', 'x' } },
      { '<leader>cx', oc 'select', desc = 'Execute opencode action…', mode = { 'n', 'x' } },
      { '<C-,>', oc 'toggle', desc = 'Toggle opencode', mode = { 'n', 't' } },
      { 'go', oc('operator', '@this '), desc = 'Add range to opencode', mode = { 'n', 'x' }, expr = true },
      { 'goo', oc('@this ' .. '_'), desc = 'Add line to opencode', expr = true },
    },
  },
}
