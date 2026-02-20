# NeoVim Modernization + Cursor Agent Integration

**Date:** 2026-02-20
**Approach:** B — Full Native LSP for simple servers + cursoragent.nvim
**Neovim version:** 0.11.6

---

## Goals

1. Modernize config to Neovim 0.11+ native APIs
2. Eliminate dead code, duplicates, and vimscript
3. Integrate `cursoragent.nvim` (uses `cursor-agent` at `~/.local/bin/cursor-agent`)

---

## Architecture

```
init.lua              Bootstrap only — no plugin setups, no duplicate calls
sets.lua              Pure vim options — remove omnifunc (blink.cmp owns it)
plugins.lua           Plugin declarations — fix vim.loop→vim.uv, add cursoragent.nvim
maps.lua              All keymaps — absorb maps.vim, add Cursor keymaps, remove nmap/vmap helpers
config.lua            DELETE — content migrated to plugin_config/
plugin_config/
  lsp.lua             lua_ls+rust_analyzer → native vim.lsp API; eslint/vtsls/vue_ls stay lspconfig
  lualine.lua         NEW — extracted from config.lua
  which_key.lua       NEW — extracted from config.lua
  (others unchanged)
```

---

## File-by-File Changes

### `init.lua`
- Remove lines 19–21: duplicate `require('telescope').setup{}` + `load_extension('fzf')`
- Remove `vim.cmd('so ~/.config/nvim/maps.vim')` — content migrated to maps.lua
- Remove conditional `.vimrc` source (no longer needed)

### `maps.vim` → deleted after migration
Content to migrate into `maps.lua`:
- `<F12>` (n + t modes) FloatermToggle → `vim.keymap.set`
- `g:floaterm_height`, `g:floaterm_width`, `g:floaterm_autoclose` → `vim.g.*`
- `check_back_space()` function → **deleted** (dead code from old coc.nvim)

### `maps.lua`
- Remove `nmap`/`vmap` helper functions and all calls to them
- Replace with `vim.keymap.set` uniformly, adding `desc` to all bindings
- Absorb floaterm bindings from maps.vim
- Add Cursor agent keymaps:

| Key | Command | Mode |
|-----|---------|------|
| `<leader>cu` | `:CursorAgent` | n |
| `<leader>cua` | `:CursorAgentAsk` | n |
| `<leader>cup` | `:CursorAgentPlan` | n |
| `<leader>cur` | `:CursorAgentResume` | n |
| `<leader>cub` | `:CursorAgentBuffer` | n |
| `<leader>cus` | `:CursorAgentSelection` | v |

### `sets.lua`
- Remove `vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"` (blink.cmp handles completion in 0.11)

### `plugins.lua`
- `vim.loop.fs_stat` → `vim.uv.fs_stat` (treesitter file size check, line ~139)
- Remove lualine `config = function() require("lualine").setup() end` block (moved to plugin_config/lualine.lua)
- Add `cursoragent.nvim`:

```lua
{
  "aug6th/cursoragent.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "CursorAgent", "CursorAgentAsk", "CursorAgentPlan",
          "CursorAgentResume", "CursorAgentBuffer", "CursorAgentSelection" },
  config = function()
    require("cursoragent").setup({})
  end,
}
```

### `config.lua` → DELETE
Migrate content:
- `vim.opt.termguicolors` / `vim.opt.number` / providers → already in sets.lua, drop dupes
- `require('lualine').setup({...})` → `plugin_config/lualine.lua`
- `require('which-key').setup({...})` → `plugin_config/which_key.lua`
- `require("nvim-web-devicons").setup({})` → move to plugins.lua `config` or drop (it's lazy)

### `plugin_config/lsp.lua`
Migrate `lua_ls` and `rust_analyzer` to native 0.11 API:

```lua
-- BEFORE
lspconfig.lua_ls.setup({ capabilities = ..., settings = { ... } })

-- AFTER
vim.lsp.config('lua_ls', { capabilities = ..., settings = { ... } })
vim.lsp.enable('lua_ls')
```

Same pattern for `rust_analyzer`. `eslint`, `vtsls`, `vue_ls` stay on `lspconfig.X.setup()`.

### `plugin_config/lualine.lua` (NEW)
Extracted from config.lua:

```lua
require('lualine').setup({
  options = { theme = 'nord', ... },
  sections = { ... },
})
```

### `plugin_config/which_key.lua` (NEW)
Extracted from config.lua:

```lua
require('which-key').setup({
  plugins = { ... },
  win = { title = false },
  preset = 'helix',
})
```

### `plugin_config/init.lua`
Add requires for the two new files:
```lua
require('plugin_config.lualine')
require('plugin_config.which_key')
```

---

## Invariants (Do Not Change)

- `vue_ls` + `vtsls` hybrid mode setup — complex `tsserver/request` handler stays untouched
- `vim.lsp.enable('ts_ls', false)` — correct 0.11 API, stays as-is
- `vim.lsp.enable('tailwindcss')` in sets.lua — already native, stays
- `oxlint` custom config at top of lsp.lua — stays
- All existing Lspsaga keymaps — stays
- `blink.cmp` with `lazy = false` — intentional, stays

---

## Success Criteria

- `nvim --startuptime` shows no regression vs baseline
- No deprecation warnings on startup
- `:checkhealth` shows no errors for LSP servers
- `cursor-agent` launches in Neovim terminal via `<leader>cu`
- maps.vim deleted, config.lua deleted
