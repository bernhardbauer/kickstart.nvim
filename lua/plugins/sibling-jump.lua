return {
  {
    'subev/sibling-jump.nvim',
    config = function()
      require('sibling_jump').setup {
        next_key = '<C-j>', -- Jump to next sibling (default)
        prev_key = '<C-k>', -- Jump to previous sibling (default)
        center_on_jump = true, -- Center screen after jump (default: false)
      }
    end,
  },
}
