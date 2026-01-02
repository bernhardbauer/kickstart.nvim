-- lua/configs/nvim-close-all.lua

local M = {}

-- Close all plugin open panels
function M.close_all_panels()
  require('neo-tree.command').execute { action = 'close' }
  require('overseer').close()
  require('neotest').summary.close()
  require('dapui').close()
end

return M
