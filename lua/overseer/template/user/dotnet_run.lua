---@type overseer.TemplateFileProvider
return {
  generator = function()
    local files = {}
    vim.list_extend(files, vim.fn.glob('*.csproj', false, true))
    vim.list_extend(files, vim.fn.glob('*/*.csproj', false, true))
    if #files == 0 then
      return {}
    end

    local ret = {}

    for _, file in ipairs(files) do
      table.insert(ret, {
        name = string.format('%s %s %s', 'dotnet', 'run', file),
        builder = function()
          return {
            cmd = { 'dotnet', 'run', '--project', file },
            -- cwd = workspace_path,
          }
        end,
      })
    end

    table.insert(ret, {
      name = 'dotnet test',
      builder = function()
        return {
          cmd = { 'dotnet', 'test' },
          -- cwd = workspace_path,
        }
      end,
    })

    return ret
  end,
  condition = {
    callback = function()
      local files = {}
      vim.list_extend(files, vim.fn.glob('*.csproj', false, true))
      vim.list_extend(files, vim.fn.glob('*/*.csproj', false, true))
      return #files > 0
    end,
  },
}
