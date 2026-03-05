-- lua/configs/nvim-close-all.lua

local M = {}

-- Close all plugin open panels
function M.close_all_panels()
  local explorer = Snacks.picker.get { source = 'explorer' }[1]
  if explorer then
    explorer:close()
  end
  require('overseer').close()
  require('neotest').summary.close()
  require('dapui').close()
end

return M
