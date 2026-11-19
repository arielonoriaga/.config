local function fail(msg)
  io.stderr:write('FAIL: ' .. msg .. '\n')
  os.exit(1)
end

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    fail(string.format('%s (expected %s, got %s)', msg, tostring(expected), tostring(actual)))
  end
end

package.path = vim.fn.stdpath('config') .. '/lua/?.lua;' .. package.path

local function init_fn()
  package.loaded['compat.treesitter_all_false'] = nil
  require('compat.treesitter_all_false').install()
end

local function make_query_mock()
  local calls = {}
  local mock = {}
  for _, fn in ipairs({ 'add_directive', 'add_predicate' }) do
    mock[fn] = function(name, handler, opts)
      calls[#calls + 1] = { fn = fn, name = name, handler = handler, opts = opts }
    end
  end
  return mock, calls
end

local function with_mocks(has_012, body)
  local orig_has = vim.fn.has
  local orig_loaded = package.loaded['vim.treesitter.query']
  local mock, calls = make_query_mock()
  package.loaded['vim.treesitter.query'] = mock
  vim.fn.has = function(feature)
    if feature == 'nvim-0.12' then return has_012 and 1 or 0 end
    return orig_has(feature)
  end
  local ok, err = pcall(body, mock, calls)
  vim.fn.has = orig_has
  package.loaded['vim.treesitter.query'] = orig_loaded
  if not ok then error(err, 0) end
end

-- 1. On nvim >= 0.12, add_directive/add_predicate get wrapped.
with_mocks(true, function()
  init_fn()
  local query = package.loaded['vim.treesitter.query']
  assert(query.add_directive ~= nil, 'add_directive should still exist after patch')
  assert(query.add_predicate ~= nil, 'add_predicate should still exist after patch')
end)

-- 2. opts.all == false: handler must receive the LAST node of each capture's
--    node list, not the first (this is the exact bug the shim fixes).
with_mocks(true, function(query, calls)
  init_fn()
  local received
  local inner = function(match, extra)
    received = match
    return 'inner-return', extra
  end
  query.add_directive('#downcase!', inner, { all = false })
  assert_eq(#calls, 1, 'add_directive should be called exactly once during setup')
  local wrapped = calls[1].handler
  local n1, n2, n3 = { id = 'n1' }, { id = 'n2' }, { id = 'n3' }
  local r1, r2 = wrapped({ [1] = { n1, n2, n3 }, [2] = { n2 } }, 'passthrough')
  assert(received ~= nil, 'inner handler was never invoked')
  assert_eq(received[1], n3, 'multi-node capture should collapse to its LAST node, not the first')
  assert_eq(received[2], n2, 'single-node capture should pass through unchanged')
  assert_eq(r1, 'inner-return', 'wrapped handler must return whatever the inner handler returns')
  assert_eq(r2, 'passthrough', 'wrapped handler must forward extra varargs to and from the inner handler')
end)

-- 3. opts.all ~= false (nil, true, or omitted `all` key): handler must be
--    passed straight through with NO transform — regressing this would
--    silently break every directive that still wants full node lists.
with_mocks(true, function(query, calls)
  init_fn()
  local inner = function(match) return match end
  query.add_predicate('#eq?', inner, { all = true })
  query.add_predicate('#has-type?', inner, nil)
  query.add_predicate('#has-type?', inner, {})
  for _, call in ipairs(calls) do
    assert_eq(call.handler, inner, 'handler must be passed through unmodified when opts.all ~= false')
  end
end)

-- 4. On nvim < 0.12, the shim must not touch add_directive/add_predicate at
--    all — this guards the version gate itself.
with_mocks(false, function(query, calls)
  local before_directive, before_predicate = query.add_directive, query.add_predicate
  init_fn()
  assert_eq(query.add_directive, before_directive, 'add_directive must be untouched on nvim < 0.12')
  assert_eq(query.add_predicate, before_predicate, 'add_predicate must be untouched on nvim < 0.12')
  assert_eq(#calls, 0, 'no add_directive/add_predicate calls should happen from init_fn itself')
end)

print('OK: treesitter_shim_spec — all assertions passed')
