-- lua/configs/nvim-dap-dotnet.lua

local M = {}

-- Find the root directory of a .NET project by searching for .csproj files
function M.find_project_root_by_csproj(start_path)
  local Path = require 'plenary.path'
  local path = Path:new(start_path)

  while true do
    local csproj_files = vim.fn.glob(path:absolute() .. '/*.csproj', false, true)
    if #csproj_files > 0 then
      return path:absolute()
    end

    local parent = path:parent()
    if parent:absolute() == path:absolute() then
      return nil
    end

    path = parent
  end
end

-- Find the highest version of the netX.Y folder within a given path.
function M.get_highest_net_folder(bin_debug_path)
  local dirs = vim.fn.glob(bin_debug_path .. '/net*', false, true) -- Get all folders starting with 'net' in bin_debug_path

  if dirs == 0 then
    error('No netX.Y folders found in ' .. bin_debug_path)
  end

  table.sort(dirs, function(a, b) -- Sort the directories based on their version numbers
    local ver_a = tonumber(a:match 'net(%d+)%.%d+')
    local ver_b = tonumber(b:match 'net(%d+)%.%d+')
    return ver_a > ver_b
  end)

  return dirs[1]
end

function M.build_debug_cwd()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
  return M.find_project_root_by_csproj(current_dir)
end

-- Run dotnet build for the project and error on failure.
function M.build_project(project_root, csproj_path)
  vim.notify('Building ' .. vim.fn.fnamemodify(csproj_path, ':t') .. '...', vim.log.levels.INFO)
  local result = vim.fn.system { 'dotnet', 'build', csproj_path, '--configuration', 'Debug' }
  if vim.v.shell_error ~= 0 then
    vim.notify('Build failed:\n' .. result, vim.log.levels.ERROR)
    error 'Build failed'
  end
  vim.notify('Build successful', vim.log.levels.INFO)
end

-- Read the first "Project" launch profile from Properties/launchSettings.json.
-- Returns env (table), args (list).
function M.read_launch_settings(project_root)
  local settings_path = project_root .. '/Properties/launchSettings.json'
  if vim.fn.filereadable(settings_path) == 0 then
    return {}, {}
  end

  local content = table.concat(vim.fn.readfile(settings_path), '\n')
  local ok, settings = pcall(vim.fn.json_decode, content)
  if not ok or not settings then
    return {}, {}
  end

  for _, profile in pairs(settings.profiles or {}) do
    if profile.commandName == 'Project' then
      local env = vim.tbl_extend('force', {}, profile.environmentVariables or {})
      if profile.applicationUrl then
        env['ASPNETCORE_URLS'] = profile.applicationUrl
      end
      local args = {}
      if profile.commandLineArgs then
        -- split on spaces, respecting simple quoting is not needed here since
        -- dotnet run passes them directly; keep as a single string if complex
        for arg in profile.commandLineArgs:gmatch '%S+' do
          table.insert(args, arg)
        end
      end
      return env, args
    end
  end

  return {}, {}
end

-- Build the project, then return the full path to the Debug .dll.
function M.build_and_get_dll_path()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')

  local project_root = M.find_project_root_by_csproj(current_dir)
  if not project_root then
    error 'Could not find project root (no .csproj found)'
  end

  local csproj_files = vim.fn.glob(project_root .. '/*.csproj', false, true)
  if #csproj_files == 0 then
    error 'No .csproj file found in project root'
  end

  M.build_project(project_root, csproj_files[1])

  local project_name = vim.fn.fnamemodify(csproj_files[1], ':t:r')
  local bin_debug_path = project_root .. '/bin/Debug'
  local highest_net_folder = M.get_highest_net_folder(bin_debug_path)
  local dll_path = highest_net_folder .. '/' .. project_name .. '.dll'

  vim.notify('Launching: ' .. dll_path, vim.log.levels.INFO)
  return dll_path
end

-- Return env vars from the active launch profile (for the DAP env field).
function M.get_launch_env()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
  local project_root = M.find_project_root_by_csproj(current_dir)
  if not project_root then
    return {}
  end
  local env, _ = M.read_launch_settings(project_root)
  return env
end

-- Return command-line args from the active launch profile (for the DAP args field).
function M.get_launch_args()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
  local project_root = M.find_project_root_by_csproj(current_dir)
  if not project_root then
    return {}
  end
  local _, args = M.read_launch_settings(project_root)
  return args
end

-- Legacy: kept for compatibility (no build step).
function M.build_dll_path()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')

  local project_root = M.find_project_root_by_csproj(current_dir)
  if not project_root then
    error 'Could not find project root (no .csproj found)'
  end

  local csproj_files = vim.fn.glob(project_root .. '/*.csproj', false, true)
  if #csproj_files == 0 then
    error 'No .csproj file found in project root'
  end

  local project_name = vim.fn.fnamemodify(csproj_files[1], ':t:r')
  local bin_debug_path = project_root .. '/bin/Debug'
  local highest_net_folder = M.get_highest_net_folder(bin_debug_path)
  local dll_path = highest_net_folder .. '/' .. project_name .. '.dll'

  print('Launching: ' .. dll_path)
  return dll_path
end

return M
