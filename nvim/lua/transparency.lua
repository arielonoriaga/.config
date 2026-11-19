local M = { enabled = true }

local SEE_THROUGH = {
  'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'SignColumn', 'LineNr', 'CursorLineNr',
  'FoldColumn', 'EndOfBuffer', 'StatusLine', 'StatusLineNC', 'WinSeparator', 'NvimTreeNormal',
  'NvimTreeNormalNC', 'TelescopeNormal', 'TelescopeBorder',
}

local function clear_backgrounds()
  for _, group in ipairs(SEE_THROUGH) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.bg = nil
    highlight.ctermbg = nil
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

function M.setup()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('Transparency', { clear = true }),
    callback = function()
      if M.enabled then
        clear_backgrounds()
      end
    end,
  })
  if M.enabled then
    clear_backgrounds()
  end
end

function M.toggle()
  M.enabled = not M.enabled
  vim.cmd.colorscheme(vim.g.colors_name)
end

return M
