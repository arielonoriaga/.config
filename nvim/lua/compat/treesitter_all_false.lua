local M = {}

local function last_node_of_each_capture(handler)
  return function(match, ...)
    local last = {}
    for id, nodes in pairs(match) do
      last[id] = nodes[#nodes]
    end
    return handler(last, ...)
  end
end

function M.install()
  if vim.fn.has('nvim-0.12') == 0 then
    return
  end
  local query = require('vim.treesitter.query')
  for _, register in ipairs({ 'add_directive', 'add_predicate' }) do
    local original = query[register]
    query[register] = function(name, handler, opts)
      local wants_single_node = type(opts) == 'table' and opts.all == false
      return original(name, wants_single_node and last_node_of_each_capture(handler) or handler, opts)
    end
  end
end

return M
