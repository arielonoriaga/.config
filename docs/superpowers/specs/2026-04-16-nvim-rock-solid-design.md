# Neovim Rock-Solid Upgrade Design

**Date:** 2026-04-16
**Scope:** Fill all technical gaps and restructure config for long-term maintainability.
**Primary languages:** TypeScript, Rust, Go. Edge cases: Vue, Svelte.

---

## 1. File Structure

Explode the monolithic `lua/plugins.lua` (475 lines) into domain modules under `lua/plugins/`.

```
nvim/lua/
├── init.lua                  (unchanged — loader)
├── sets.lua                  (fold method change only)
├── maps.lua                  (add: rename, signature help, inlay hints keymaps)
├── plugins/
│   ├── init.lua              (lazy.setup() — imports all modules)
│   ├── core.lua              (plenary, nui, devicons, dressing)
│   ├── ai.lua                (supermaven, claude-code, cursoragent)
│   ├── ui.lua                (lualine, noice, notify, which-key, themery + themes)
│   ├── editor.lua            (treesitter, autopairs, autotag, comment, gitsigns,
│   │                          spectre, sandwich, floaterm, nvim-tree, telescope)
│   ├── lsp.lua               (nvim-lspconfig, mason, mason-lspconfig, lspsaga)
│   ├── completion.lua        (blink.cmp + friendly-snippets — add snippet Tab nav)
│   ├── formatting.lua        (conform.nvim — NEW)
│   ├── debugging.lua         (nvim-dap + dap-ui + dap-virtual-text — NEW)
│   └── diagnostics.lua       (trouble.nvim v3 — NEW)
└── plugin_config/
    ├── lsp.lua               (add gopls, inlay hint autocmd, fix noice inc_rename)
    ├── telescope.lua         (unchanged)
    ├── noice.lua             (inc_rename = true)
    ├── completions.lua       (unchanged)
    └── themery.lua           (unchanged)
```

`init.lua` changes: `require('plugins')` now resolves to `plugins/init.lua`.
Old `plugins.lua` is deleted once migration is complete.

---

## 2. LSP Layer

### New server: gopls
```lua
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      analyses    = { unusedparams = true, shadow = true },
      staticcheck = true,
      gofumpt     = true,
    },
  },
})
vim.lsp.enable('gopls')
```

### Inlay hints
Enabled per-buffer via `LspAttach` autocmd. Only activates when the server supports `textDocument/inlayHint`.

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
```

### New keymaps (maps.lua)
| Key | Action |
|-----|--------|
| `<leader>rn` | `vim.lsp.buf.rename()` |
| `<C-k>` (n + i) | `vim.lsp.buf.signature_help()` |
| `<leader>ih` | toggle inlay hints (buffer-local) |

### noice.lua
`inc_rename = false` → `inc_rename = true` — enables live preview input on rename.

---

## 3. Formatting Layer

New file: `plugins/formatting.lua`

Plugin: `stevearc/conform.nvim`

### Formatters
| Language | Formatter | Install |
|----------|-----------|---------|
| TypeScript / JS / JSX / TSX | `prettierd` | Mason |
| Vue / Svelte | `prettierd` | Mason (same binary) |
| Rust | `rustfmt` | rustup (pre-installed) |
| Go | `goimports` | Mason |
| Lua | `stylua` | Mason |

Mason auto-installer: `WhoIsSethDaniel/mason-tool-installer.nvim`
Ensures `prettierd`, `stylua`, `goimports` are present on first launch.

### Behavior
- Format on save with 500ms timeout + async fallback
- Respects `.editorconfig` and `biome.json` automatically
- Falls back silently if formatter not installed
- `<leader>cf` → manual format (works even if auto-save is off)

---

## 4. Debugging Layer

New file: `plugins/debugging.lua`

Plugins: `mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui`, `theHamsta/nvim-dap-virtual-text`, `leoluz/nvim-dap-go`

### Adapters
| Language | Adapter | Install |
|----------|---------|---------|
| TypeScript / JS | `vscode-js-debug` | Mason |
| Rust | `codelldb` | Mason |
| Go | `delve` | Mason + `nvim-dap-go` plugin |

### Keymaps (`<leader>d` namespace)
| Key | Action |
|-----|--------|
| `<leader>db` | toggle breakpoint |
| `<leader>dB` | conditional breakpoint |
| `<leader>dc` | continue / start session |
| `<leader>ds` | step over |
| `<leader>dI` | step into (capital I — avoids clash with `<leader>dic`) |
| `<leader>dO` | step out (capital O — avoids clash with `<leader>doc`) |
| `<leader>dr` | open REPL |
| `<leader>du` | toggle DAP UI |
| `<leader>dq` | terminate session (avoids clash with `<leader>dts`) |

### DAP UI
Auto-opens on session start, auto-closes on exit. Panels: locals, watches, stack frames, breakpoints.

### Virtual text
`nvim-dap-virtual-text` shows live variable values inline while paused on a breakpoint.

---

## 5. Diagnostics Layer

New file: `plugins/diagnostics.lua`

Plugin: `folke/trouble.nvim` v3

### Keymaps
| Key | Action |
|-----|--------|
| `<leader>xx` | workspace diagnostics |
| `<leader>xd` | document diagnostics |
| `<leader>xq` | quickfix list |

---

## 6. Completion — Snippet Navigation

Edit `plugins/completion.lua` (blink.cmp opts):

```lua
keymap = {
  preset = 'default',
  ['<CR>']    = { 'accept', 'fallback' },
  ['<Tab>']   = { 'snippet_forward', 'fallback' },
  ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
},
```

Tab jumps between snippet placeholders when inside a snippet, falls through otherwise.

---

## 7. Treesitter

### Additional parsers (`plugins/editor.lua`)
Add to `ensure_installed`:
```lua
"go", "rust", "yaml", "toml", "dockerfile", "graphql", "sql"
```

### Fold method (`sets.lua`)
```lua
-- Before
foldmethod = "syntax",
foldlevelstart = 2,
foldnestmax    = 2,

-- After
foldmethod  = "expr",
foldexpr    = "nvim_treesitter#foldexpr()",
foldenable  = false,   -- files open unfolded by default
```

`foldenable = false` means folds exist but are open until you close them (`zc`). Better UX than everything collapsing on open.

---

## Implementation Order

1. Create `plugins/` directory structure, split `plugins.lua` into modules
2. Add gopls + inlay hints + new keymaps to `plugin_config/lsp.lua` and `maps.lua`
3. Add `plugins/formatting.lua` (conform.nvim)
4. Add `plugins/debugging.lua` (DAP stack)
5. Add `plugins/diagnostics.lua` (trouble.nvim)
6. Update `plugins/completion.lua` (snippet Tab nav)
7. Update `plugins/editor.lua` (treesitter parsers + fold method in sets.lua)
8. Delete old `lua/plugins.lua`
9. Smoke test: open TS, Rust, Go files — verify LSP, format-on-save, DAP launch
