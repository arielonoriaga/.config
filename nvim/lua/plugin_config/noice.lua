local noice = require('noice')

noice.setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

local notify = require('notify')

vim.notify = function(msg, log_level, opts)
    if type(msg) == 'string' and msg:match('code_action') then
        return -- Suppress null-ls code_action notifications
    end
    notify(msg, log_level, opts)
end

notify.setup({
  render = "wrapped-compact",
  max_width = 80,
  stages = "slide"
})

