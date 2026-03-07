local M = {}

-- Map each boolean keyword to its opposite
local pairs = {
  ['true'] = 'false',
  ['false'] = 'true',
  ['True'] = 'False',
  ['False'] = 'True',
  ['TRUE'] = 'FALSE',
  ['FALSE'] = 'TRUE',
}

-- Try to toggle the word under the cursor.
-- Returns true if a toggle was performed, false otherwise.
function M.toggle()
  local word = vim.fn.expand '<cword>'
  local replacement = pairs[word]
  if replacement then
    vim.cmd('normal! ciw' .. replacement)
    return true
  end
  return false
end

return M
