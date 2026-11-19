local M = {}

local FALLBACK = 'cyberdream'

local function saved_themery_choice()
  local file = io.open(vim.fn.stdpath('data') .. '/themery/state.json', 'r')
  if not file then
    return nil
  end
  local ok, state = pcall(vim.json.decode, file:read('*a'))
  file:close()
  return ok and type(state) == 'table' and state or nil
end

function M.apply()
  local state = saved_themery_choice()
  if state and state.beforeCode and state.beforeCode ~= '' then
    pcall(load(state.beforeCode))
  end
  if not (state and pcall(vim.cmd.colorscheme, state.colorscheme)) then
    pcall(vim.cmd.colorscheme, FALLBACK)
  end
end

return M
