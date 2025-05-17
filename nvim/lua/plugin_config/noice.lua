local noice = require('noice')

noice.setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  routes = {
    {
      filter = {
        event = "notify",
        find = "No information available",
      },
      opts = { skip = true },
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
})

local notify = require('notify')

vim.notify = function(msg, log_level, opts)
  if type(msg) == 'string' and msg:match('code_action') then
    return
  end
  notify(msg, log_level, opts)
end

notify.setup({
  render = "compact",
  max_width = 80,
  stages = "slide",
  top_down = false,
})

