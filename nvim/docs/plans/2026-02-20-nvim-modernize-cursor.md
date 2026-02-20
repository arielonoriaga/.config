# NeoVim Modernization + Cursor Agent Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize the NeoVim config to 0.11+ native APIs, eliminate vimscript and config duplication, and integrate `cursoragent.nvim` for AI-assisted coding inside Neovim.

**Architecture:** Clean up `init.lua` duplicates, absorb `maps.vim` into `maps.lua`, migrate `lua_ls`/`rust_analyzer` to native `vim.lsp` API while keeping `lspconfig` for the complex Vue/TS stack, and add `cursoragent.nvim` with `<leader>cu` keymaps. `config.lua` is deleted — its lualine/which-key configs move into their plugin specs in `plugins.lua`.

**Tech Stack:** Neovim 0.11.6, lazy.nvim, lspconfig, blink.cmp, lspsaga, cursoragent.nvim (`cursor-agent` at `~/.local/bin/cursor-agent`)

---

## Key File Map

```
~/.config/nvim/
  init.lua                      — bootstrap loader
  lua/
    sets.lua                    — vim options
    plugins.lua                 — lazy.nvim plugin declarations
    maps.lua                    — all keymaps
    config.lua                  — TO BE DELETED
    plugin_config/
      init.lua                  — loads all plugin configs
      lsp.lua                   — LSP server configurations
      noice.lua / telescope.lua / themery.lua / completions.lua
  maps.vim                      — vimscript file TO BE DELETED
```

---

## Task 1: Record Startup Baseline

**Files:** None — just measuring

**Step 1: Record current startup time**

```bash
nvim --startuptime /tmp/nvim-before.log +quit
sort -k2 -n /tmp/nvim-before.log | tail -20
```

Expected: A list of plugins with load times. Note the total at the bottom.

**Step 2: Save the total for comparison later**

```bash
tail -1 /tmp/nvim-before.log
```

Keep this number. We'll compare after all tasks are done.

---

## Task 2: Fix `vim.loop` Deprecation in `plugins.lua`

**Files:**
- Modify: `lua/plugins.lua` (around line 139)

**Step 1: Find the deprecated call**

Open `lua/plugins.lua` and search for `vim.loop`. It's in the treesitter `highlight.disable` function:

```lua
local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
```

**Step 2: Replace with `vim.uv`**

Change that line to:

```lua
local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
```

**Step 3: Verify no other `vim.loop` usages**

```bash
grep -rn "vim\.loop" ~/.config/nvim/lua/
```

Expected: No results.

**Step 4: Test nvim starts without deprecation warning**

```bash
nvim --cmd "lua vim.g._test=1" +quit 2>&1 | grep -i "deprecat\|loop"
```

Expected: No output.

**Step 5: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins.lua
git commit -m "fix: replace deprecated vim.loop with vim.uv in treesitter config"
```

---

## Task 3: Clean Up `init.lua`

**Files:**
- Modify: `init.lua`

Current `init.lua` has these problems:
- Lines 19–21: `require('telescope').setup{}` + `load_extension('fzf')` — already done inside telescope's `config` in `plugins.lua`. This double-runs and triggers an eager load.
- Line 14: `vim.cmd('so ~/.config/nvim/maps.vim')` — loads vimscript. Will be removed after Task 4.
- Lines 15–17: conditional `.vimrc` source — not needed, remove now.

**Step 1: Remove the vimrc source block**

In `init.lua`, remove lines 15–17:
```lua
if vim.fn.filereadable(vim.fn.expand('~/.vimrc')) == 1 then
  vim.cmd('so ~/.vimrc')
end
```

**Step 2: Remove the duplicate telescope setup (lines 19–21)**

Remove:
```lua
require('telescope').setup{}
require('telescope').load_extension('fzf')
```

The `init.lua` require section should now end at:
```lua
require('sets')
require('plugins')
require('plugin_config')
require('config')
require('maps')

-- Load VimScript configs last
vim.cmd('so ~/.config/nvim/maps.vim')

-- vim.lsp.set_log_level("debug")
vim.cmd("highlight ColorColumn guibg=#533c5b")
```

(The `maps.vim` line stays for now — removed in Task 4.)

**Step 3: Verify nvim starts cleanly**

```bash
nvim --headless +quit 2>&1
```

Expected: No errors printed.

**Step 4: Commit**

```bash
git add init.lua
git commit -m "fix: remove duplicate telescope setup and vimrc sourcing from init.lua"
```

---

## Task 4: Migrate `maps.vim` → `maps.lua` and Delete `maps.vim`

**Files:**
- Modify: `lua/maps.lua` (add content from maps.vim)
- Modify: `init.lua` (remove `vim.cmd('so ...')` line)
- Delete: `maps.vim`

Current `maps.vim` content:
```viml
nnoremap <silent><F12> :FloatermToggle --name=cmd<CR>
tnoremap <silent><F12> <C-\><C-n>:FloatermToggle --name=cmd<CR>

let g:floaterm_height = 0.9
let g:floaterm_width = 0.9
let g:floaterm_autoclose = 2

function! s:check_back_space() abort   ← DEAD CODE, do not migrate
  ...
endfunction
```

**Step 1: Add floaterm settings and keymaps to `maps.lua`**

At the top of `maps.lua` (before the local function definitions), add:

```lua
-- Floaterm settings (migrated from maps.vim)
vim.g.floaterm_height = 0.9
vim.g.floaterm_width = 0.9
vim.g.floaterm_autoclose = 2
```

At the end of `maps.lua`, add the F12 keymaps:

```lua
-- Floaterm toggle (migrated from maps.vim)
vim.keymap.set('n', '<F12>', '<cmd>FloatermToggle --name=cmd<CR>', { noremap = true, silent = true, desc = 'Toggle terminal' })
vim.keymap.set('t', '<F12>', '<C-\\><C-n><cmd>FloatermToggle --name=cmd<CR>', { noremap = true, silent = true, desc = 'Toggle terminal' })
```

Note: `<C-\><C-n>` in lua strings — the backslash is literal since it's inside a keymap string processed by nvim, not Lua escape. This is correct.

**Step 2: Remove `maps.vim` source line from `init.lua`**

Remove from `init.lua`:
```lua
-- Load VimScript configs last
vim.cmd('so ~/.config/nvim/maps.vim')
```

And the comment `-- Load VimScript configs last` too.

**Step 3: Delete `maps.vim`**

```bash
rm ~/.config/nvim/maps.vim
```

**Step 4: Test F12 works**

Open nvim, press `<F12>`. A floating terminal should appear. Press `<F12>` again to close it.

**Step 5: Commit**

```bash
cd ~/.config/nvim
git add init.lua lua/maps.lua
git rm maps.vim
git commit -m "feat: migrate maps.vim to lua and delete vimscript file"
```

---

## Task 5: Modernize `maps.lua` — Remove Helper Functions

**Files:**
- Modify: `lua/maps.lua`

The file currently has:
```lua
local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end
local function nmap(shortcut, command) map('n', shortcut, command) end
local function vmap(shortcut, command) map('v', shortcut, command) end
```

These helpers don't support `desc`, which means which-key can't label them. Replace all uses with `vim.keymap.set`.

**Step 1: Replace all helper-based keymaps**

Replace the helper function block and all calls with direct `vim.keymap.set`. The full replacement:

```lua
-- REMOVE these lines:
local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end
local function nmap(shortcut, command) map('n', shortcut, command) end
local function vmap(shortcut, command) map('v', shortcut, command) end

-- REMOVE these calls and REPLACE with vim.keymap.set equivalents:
nmap('<leader>lg', '<cmd>LazyGit<CR>')
-- becomes:
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<CR>', { noremap = true, silent = true, desc = 'LazyGit' })

nmap('<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>')
-- becomes:
vim.keymap.set('n', '<leader>ld', '<cmd>FloatermNew --name=lazydocker lazydocker<CR>', { noremap = true, silent = true, desc = 'LazyDocker' })

nmap('<C-q>', ':q<CR>')
-- becomes:
vim.keymap.set('n', '<C-q>', ':q<CR>', { noremap = true, silent = true, desc = 'Quit' })

nmap('<C-s>', ':w<CR>')
-- becomes:
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true, desc = 'Save' })

nmap('dd', '"_dd')
-- becomes:
vim.keymap.set('n', 'dd', '"_dd', { noremap = true, silent = true, desc = 'Delete line (no yank)' })

nmap('fn', ":let @+=expand('%:t:r')<CR>")
-- becomes:
vim.keymap.set('n', 'fn', ":let @+=expand('%:t:r')<CR>", { noremap = true, silent = true, desc = 'Copy filename' })

vmap('cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>")
-- becomes:
vim.keymap.set('v', 'cl', "yA<cr>console.log('')<esc>hi<C-o>P<esc>2li, <C-o>P<esc>", { noremap = true, silent = true, desc = 'Console.log selection' })

nmap('<leader>crp', ":let @+=expand('%')<CR>")
-- becomes:
vim.keymap.set('n', '<leader>crp', ":let @+=expand('%')<CR>", { noremap = true, silent = true, desc = 'Copy relative path' })

nmap('<leader>crpt', ":let @+=expand('%:r:r')<CR>")
-- becomes:
vim.keymap.set('n', '<leader>crpt', ":let @+=expand('%:r:r')<CR>", { noremap = true, silent = true, desc = 'Copy path (no ext)' })

nmap('<leader>reload', ':source ~/.vimrc<CR>')
-- REMOVE — we no longer use .vimrc

nmap('<leader>rs', ':noh<CR>')
-- becomes:
vim.keymap.set('n', '<leader>rs', ':noh<CR>', { noremap = true, silent = true, desc = 'Clear search highlight' })

nmap('<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>')
-- becomes:
vim.keymap.set('n', '<leader>dts', ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar>:noh<CR>', { noremap = true, silent = true, desc = 'Delete trailing spaces' })
```

Also replace the `vim.api.nvim_set_keymap` call for `<leader>o`:
```lua
-- REMOVE:
vim.api.nvim_set_keymap('n', '<leader>o', ':!thunar %:p:h<CR><CR>', { noremap = true, silent = true })
-- REPLACE WITH:
vim.keymap.set('n', '<leader>o', ':!thunar %:p:h<CR><CR>', { noremap = true, silent = true, desc = 'Open file manager' })
```

**Step 2: Verify nvim starts and all keymaps work**

Open nvim and press `<leader>` — which-key should show labeled bindings for all migrated keys.

**Step 3: Commit**

```bash
git add lua/maps.lua
git commit -m "refactor: replace nmap/vmap helpers with vim.keymap.set in maps.lua"
```

---

## Task 6: Clean Up `sets.lua`

**Files:**
- Modify: `lua/sets.lua`

Two changes:
1. Remove `vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"` — blink.cmp handles completion in 0.11, this is unused noise
2. Uncomment `relativenumber` — currently commented out in sets.lua but enabled in config.lua. When we delete config.lua in Task 8, we'd lose this.

**Step 1: Remove omnifunc line**

Find and delete:
```lua
vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"
```

**Step 2: Enable relativenumber in sets.lua**

In the `ui` table, uncomment:
```lua
-- relativenumber = true,
```
Change to:
```lua
relativenumber = true,
```

**Step 3: Verify**

Open nvim — line numbers should show as relative. LSP completion via blink.cmp should still work.

**Step 4: Commit**

```bash
git add lua/sets.lua
git commit -m "chore: remove legacy omnifunc, enable relativenumber in sets.lua"
```

---

## Task 7: Move Lualine and Which-Key Configs Inline in `plugins.lua`

**Files:**
- Modify: `lua/plugins.lua`

`config.lua` currently holds the full lualine and which-key setup. These need to move into the plugin spec `config` functions in `plugins.lua` so lazy loading timing is preserved.

**Step 1: Replace lualine's `config` function in `plugins.lua`**

Find the current lualine entry (around line 311):
```lua
{
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',
  config = function ()
    require("lualine").setup()
  end
},
```

Replace the `config` function with the full config from `config.lua`:
```lua
{
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',
  config = function()
    require('lualine').setup({
      options = {
        theme = 'nord',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {{
          'mode',
          fmt = function(str) return str:sub(1,1) end
        }},
        lualine_b = { 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = { 'progress' },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
},
```

**Step 2: Replace which-key's `opts` with a full `config` function in `plugins.lua`**

Find the current which-key entry:
```lua
{
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    presets = { operators = false },
  },
},
```

Replace with the full config from `config.lua`:
```lua
{
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
      },
      win = {
        title = false,
      },
      preset = 'helix',
    })
  end,
},
```

**Step 3: Verify nvim starts with correct lualine theme and which-key**

Open nvim — lualine should show the nord theme with single-char mode indicator. Press `<leader>` — which-key should open with helix preset.

**Step 4: Commit**

```bash
git add lua/plugins.lua
git commit -m "refactor: move lualine and which-key configs inline in plugins.lua"
```

---

## Task 8: Delete `config.lua`

**Files:**
- Modify: `init.lua` (remove `require('config')`)
- Delete: `lua/config.lua`

At this point, all content from `config.lua` has been migrated:
- `termguicolors`, `number` → already in `sets.lua` (duplicates)
- `relativenumber` → moved to `sets.lua` in Task 6
- providers → already in `sets.lua` (duplicates)
- `nvim-web-devicons` setup → the plugin works without explicit `setup({})` (it's already declared)
- lualine config → moved to `plugins.lua` in Task 7
- which-key config → moved to `plugins.lua` in Task 7

**Step 1: Remove `require('config')` from `init.lua`**

In `init.lua`, remove:
```lua
require('config')
```

**Step 2: Delete `config.lua`**

```bash
rm ~/.config/nvim/lua/config.lua
```

**Step 3: Verify nvim starts cleanly**

```bash
nvim --headless +quit 2>&1
```

Expected: No "module not found" or other errors.

Open nvim interactively — check lualine, which-key, and relative numbers are all working.

**Step 4: Commit**

```bash
cd ~/.config/nvim
git add init.lua
git rm lua/config.lua
git commit -m "chore: delete config.lua after migrating all content to plugins.lua and sets.lua"
```

---

## Task 9: Migrate `lua_ls` to Native Neovim 0.11 LSP API

**Files:**
- Modify: `lua/plugin_config/lsp.lua`

**Context:** Neovim 0.11 ships with `vim.lsp.config()` and `vim.lsp.enable()`. When `nvim-lspconfig` is installed, its `lsp/` directory (containing server definitions) is added to runtimepath. So `vim.lsp.config('lua_ls', {...})` finds the default `lua_ls` config from lspconfig and merges with our overrides. This replaces `lspconfig.lua_ls.setup({...})`.

**Step 1: Replace `lspconfig.lua_ls.setup` with native API**

Find in `lua/plugin_config/lsp.lua`:
```lua
lspconfig.lua_ls.setup({
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})
```

Replace with:
```lua
vim.lsp.config('lua_ls', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})
vim.lsp.enable('lua_ls')
```

**Step 2: Test lua_ls works**

Open `~/.config/nvim/init.lua` in nvim. Run:
```
:LspInfo
```

Expected: `lua_ls` should appear as attached. Hover over `vim.g` — hover doc should appear.

**Step 3: Commit**

```bash
git add lua/plugin_config/lsp.lua
git commit -m "refactor: migrate lua_ls to native vim.lsp.config API (nvim 0.11)"
```

---

## Task 10: Migrate `rust_analyzer` to Native Neovim 0.11 LSP API

**Files:**
- Modify: `lua/plugin_config/lsp.lua`

**Step 1: Replace `lspconfig.rust_analyzer.setup` with native API**

Find:
```lua
lspconfig.rust_analyzer.setup({
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    }
  }
})
```

Replace with:
```lua
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})
vim.lsp.enable('rust_analyzer')
```

**Step 2: Test rust_analyzer works (if you have a Rust file)**

If you have a Rust project handy:
```bash
nvim /path/to/some/file.rs
```

Run `:LspInfo` — `rust_analyzer` should appear attached.

If no Rust file available: just verify nvim starts without errors.

**Step 3: Commit**

```bash
git add lua/plugin_config/lsp.lua
git commit -m "refactor: migrate rust_analyzer to native vim.lsp.config API (nvim 0.11)"
```

---

## Task 11: Add `cursoragent.nvim` to `plugins.lua`

**Files:**
- Modify: `lua/plugins.lua`

**Context:** `cursor-agent` binary is at `~/.local/bin/cursor-agent` (in PATH). The plugin `aug6th/cursoragent.nvim` creates an in-editor terminal interface to cursor-agent with MCP server communication, diff visualization, and multiple modes (agent, ask, plan, resume).

**Step 1: Add the plugin entry to `plugins.lua`**

Add after the `greggh/claude-code.nvim` block (around line 79), before the `-- UI and utilities` comment:

```lua
-- Cursor Agent integration
{
  "aug6th/cursoragent.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "CursorAgent",
    "CursorAgentAsk",
    "CursorAgentPlan",
    "CursorAgentResume",
    "CursorAgentBuffer",
    "CursorAgentSelection",
  },
  config = function()
    require("cursoragent").setup({})
  end,
},
```

**Step 2: Install the plugin**

Open nvim and run:
```
:Lazy sync
```

Wait for it to install `aug6th/cursoragent.nvim`.

**Step 3: Verify plugin is installed**

```
:Lazy
```

Find `cursoragent.nvim` — it should show as installed (not loaded yet, since it's cmd-lazy).

**Step 4: Commit**

```bash
git add lua/plugins.lua
git commit -m "feat: add cursoragent.nvim for Cursor AI agent in Neovim"
```

---

## Task 12: Add Cursor Agent Keymaps to `maps.lua`

**Files:**
- Modify: `lua/maps.lua`

**Step 1: Add Cursor agent keymaps at the end of `maps.lua`**

```lua
-- Cursor Agent (<leader>cu namespace)
vim.keymap.set('n', '<leader>cu', '<cmd>CursorAgent<CR>', { noremap = true, silent = true, desc = 'Cursor Agent' })
vim.keymap.set('n', '<leader>cua', '<cmd>CursorAgentAsk<CR>', { noremap = true, silent = true, desc = 'Cursor Agent Ask' })
vim.keymap.set('n', '<leader>cup', '<cmd>CursorAgentPlan<CR>', { noremap = true, silent = true, desc = 'Cursor Agent Plan' })
vim.keymap.set('n', '<leader>cur', '<cmd>CursorAgentResume<CR>', { noremap = true, silent = true, desc = 'Cursor Agent Resume' })
vim.keymap.set('n', '<leader>cub', '<cmd>CursorAgentBuffer<CR>', { noremap = true, silent = true, desc = 'Cursor Agent Buffer' })
vim.keymap.set('v', '<leader>cus', '<cmd>CursorAgentSelection<CR>', { noremap = true, silent = true, desc = 'Cursor Agent Selection' })
```

**Step 2: Test Cursor agent launches**

Open nvim and press `<leader>cu`. A terminal should open with cursor-agent running. Try asking it a question.

**Step 3: Test selection mode**

Select some code in visual mode, then press `<leader>cus`. The agent should receive the selection.

**Step 4: Commit**

```bash
git add lua/maps.lua
git commit -m "feat: add cursor agent keymaps under <leader>cu namespace"
```

---

## Task 13: Final Verification

**Step 1: Check startup time improvement**

```bash
nvim --startuptime /tmp/nvim-after.log +quit
tail -1 /tmp/nvim-after.log
```

Compare with the baseline from Task 1.

**Step 2: Check for deprecation warnings**

```bash
nvim --headless --cmd "lua vim.defer_fn(function() vim.cmd('qa') end, 100)" 2>&1 | grep -i "deprecat\|warn\|error"
```

Expected: No output.

**Step 3: Check LSP health**

Open a TypeScript or Vue file, then run:
```
:checkhealth lsp
```

Verify `lua_ls`, `rust_analyzer` (if applicable), `vtsls`, `vue_ls`, `eslint` all show as healthy.

**Step 4: Verify no `vim.loop` references remain**

```bash
grep -rn "vim\.loop" ~/.config/nvim/lua/
```

Expected: No results.

**Step 5: Verify no vimscript files remain**

```bash
ls ~/.config/nvim/*.vim 2>/dev/null && echo "VimScript files found!" || echo "Clean - no .vim files"
```

Expected: `Clean - no .vim files`

**Step 6: Verify config.lua is gone**

```bash
ls ~/.config/nvim/lua/config.lua 2>/dev/null && echo "STILL EXISTS" || echo "Deleted"
```

Expected: `Deleted`

**Step 7: Final commit**

```bash
cd ~/.config/nvim
git add -A
git commit -m "chore: final verification pass - nvim modernization complete"
```

---

## Summary of All Changes

| Task | Files Changed | Risk |
|------|--------------|------|
| 1 | none | none |
| 2 | plugins.lua | low |
| 3 | init.lua | low |
| 4 | maps.lua, init.lua, delete maps.vim | low |
| 5 | maps.lua | low |
| 6 | sets.lua | low |
| 7 | plugins.lua | medium (lazy load timing) |
| 8 | init.lua, delete config.lua | medium |
| 9 | plugin_config/lsp.lua | medium (lua_ls) |
| 10 | plugin_config/lsp.lua | medium (rust_analyzer) |
| 11 | plugins.lua | low |
| 12 | maps.lua | low |
| 13 | none | none |
