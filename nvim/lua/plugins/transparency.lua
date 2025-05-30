local M = {}

M.transparent = false

M.set_transparent = function()
  vim.cmd [[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
    highlight VertSplit guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
    highlight StatusLine guibg=NONE ctermbg=NONE
    highlight StatusLineNC guibg=NONE ctermbg=NONE
    highlight TabLine guibg=NONE ctermbg=NONE
    highlight TabLineFill guibg=NONE ctermbg=NONE
    highlight TabLineSel guibg=NONE ctermbg=NONE
    highlight Pmenu guibg=NONE ctermbg=NONE
    highlight PmenuSel guibg=NONE ctermbg=NONE
    highlight FloatBorder guibg=NONE ctermbg=NONE
  ]]
end

M.reset_background = function()
  vim.cmd [[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=bg
    highlight VertSplit guibg=bg
    highlight LineNr guibg=bg
    highlight SignColumn guibg=bg
    highlight StatusLine guibg=bg
    highlight StatusLineNC guibg=bg
    highlight TabLine guibg=bg
    highlight TabLineFill guibg=bg
    highlight TabLineSel guibg=bg
    highlight Pmenu guibg=bg
    highlight PmenuSel guibg=bg
    highlight FloatBorder guibg=bg
  ]]
end

M.toggle = function()
  M.transparent = not M.transparent
  if M.transparent then
    M.set_transparent()
    print("Transparency ON")
  else
    M.reset_background()
    print("Transparency OFF")
  end
end

return M
