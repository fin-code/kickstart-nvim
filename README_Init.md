# Kickstart Neovim Config — Explained

This README explains your `init.lua` line-by-line at a friendly, high level. It covers settings, plugins, how they fit together, and every shortcut you can use.

> If you’re new to Vim/Neovim:

- Run `:Tutor` once to learn the basics.
- Use `:help` often; it’s _the_ place to look things up.
- In this config, `<space>sh` searches help quickly.

## 1. Leaders (spacebar as your “prefix”)
===================================
```lua
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
```

- The **leader** and **localleader** keys are both set to **Space**.
- This must be defined **before** any plugins load, so your plugin keymaps are built around it.

## 2) Quality-of-Life Settings (what you’ll notice day-to-day)
===================================
```lua
vim.o.number = true          -- Line numbers
vim.o.mouse = 'a'            -- Mouse support
vim.o.showmode = false       -- Hide default -- INSERT -- indicator (statusline shows it)
vim.o.breakindent = true     -- Wrapped lines keep indent
vim.o.undofile = true        -- Persistent undo across sessions
vim.o.ignorecase = true      -- Case-insensitive search…
vim.o.smartcase = true       -- …unless you use capitals
vim.o.signcolumn = 'yes'     -- Keep sign column visible (diagnostics/git)
vim.o.updatetime = 250       -- Faster CursorHold/diagnostic updates
vim.o.timeoutlen = 300       -- WhichKey/Tmux-friendly mapping timeout
vim.o.splitright = true      -- New vertical splits open to the right
vim.o.splitbelow = true      -- New horizontal splits open below
vim.o.list = true            -- Show invisible chars
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'   -- Live preview for :s substitutions
vim.o.cursorline = true      -- Highlight current line
vim.o.scrolloff = 10         -- Keep 10 lines visible around cursor
vim.o.confirm = true         -- Ask to save on :q if there are changes
```

- Clipboard is synced to your OS after UI loads (faster startup):
  ```lua
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
  ```

## 3) Small but Mighty Automations
===================================
**Yank highlight** – flashes yanked (copied) text so you get visual feedback:

```lua
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
```

## 4) Plugin Manager: `lazy.nvim`
===================================
Your config bootstraps [`lazy.nvim`](https://github.com/folke/lazy.nvim) on first run and then calls `require('lazy').setup({ ... })` with a curated plugin list. Use:

- `:Lazy` — view plugin status, press `?` for help.
- `:Lazy update` — update plugins.

## 5) Plugins (what each one does here)
===================================
- **NMAC427/guess-indent.nvim** – auto-detects indentation per file.
- **lewis6991/gitsigns.nvim** – Git change marks (+ ~ \_) in the sign column. Config sets symbols.
- **folke/which-key.nvim** – popup that shows available keychains after you press `<leader>`; configured with friendly icons and groups.
- **nvim-telescope/telescope.nvim** (+ `fzf` + `ui-select`) – fuzzy finder for files, help, diagnostics, symbols, etc. Keymaps are defined for common actions (see the table below).
- **neovim/nvim-lspconfig** (+ **mason.nvim**, **mason-lspconfig**, **mason-tool-installer**, **j-hui/fidget.nvim**) – LSP setup: jump to definition, references, rename, code actions, diagnostics, and status updates. Lua LSP is customized; tools are ensured via Mason.
- **saghen/blink.cmp** – autocompletion engine integrated with LSP, paths, and snippets.
- **L3MON4D3/LuaSnip** – snippet engine used by completion.
- **stevearc/conform.nvim** – formatter runner; `<leader>f` formats the buffer; Lua uses `stylua`.
- **folke/tokyonight.nvim** – theme (comments not italicized); default style: `tokyonight-night`.
- **folke/todo-comments.nvim** – highlights TODO/NOTE/FIX, etc.
- **echasnovski/mini.nvim** – handy collection; you’re using:
  - `mini.ai` (better text objects)
  - `mini.surround` (surroundings editing)
  - `mini.statusline` (clean statusline; shows `line:col`)
- **nvim-treesitter/nvim-treesitter** – modern syntax and indentation; auto installs parsers; `ensure_installed` includes Lua, Vimscript, Markdown, etc.

> Tip: To modularize, uncomment `{ import = 'custom.plugins' }` and add files under `lua/custom/plugins/*.lua`.

## 6) LSP (Language Server Protocol)
===================================

- Attaches smart keymaps **per buffer** when a server connects, so LSP features “just work” in that filetype.
- Extra niceties: reference highlighting on cursor hold, inlay hints toggle, and Telescope-powered pickers for definitions, references, symbols, etc.
- **Lua** server (`lua_ls`) is configured to make Lua completion snippety and ergonomic.
- Mason ensures required tools/servers are present.

## 7) Formatting & Completion

- **Formatting:** `<leader>f` invokes Conform. It tries LSP formatting and falls back to external tools; Lua uses `stylua`. Format-on-save is enabled for most languages (C/C++ excluded by default).
- **Completion:** Blink CMP uses the “default” keymap preset (see Blink docs), supports docs on `<C-Space>`, and integrates with LuaSnip.

## 8) Theme
===================================

```lua
require('tokyonight').setup({ styles = { comments = { italic = false } } })
vim.cmd.colorscheme 'tokyonight-night'
```

Clean, high-contrast theme with no italic comments.

## 9) Treesitter
===================================

- Ensures parsers for: `bash`, `c`, `diff`, `html`, `lua`, `luadoc`, `markdown(_inline)`, `query`, `vim`, `vimdoc`.
- `auto_install = true` – missing parsers will be fetched.
- Indent and highlight are enabled (Ruby uses Vim regex indent).

## 10) All Shortcuts (Cheat Sheet)

> **Legend:**
>
> - **Mode**: `n` = normal, `t` = terminal, `i` = insert, `x` = visual.
> - **Leader** = `<space>`

| Mode | Keys               | Action                         | Provided by / Where  | Notes                                     |
| ---- | ------------------ | ------------------------------ | -------------------- | ----------------------------------------- |
| n    | `<Esc>`            | Clear search highlights        | Built-in mapping     | Handy after `/` or `*`.                   |
| n    | `<leader>q`        | Open diagnostics quickfix list | Diagnostics API      | Shows all current issues.                 |
| t    | `<Esc><Esc>`       | Exit terminal mode             | Built-in mapping     | Alternative to `<C-\><C-n>`.              |
| n    | `<C-h>`            | Focus left split               | Built-in mapping     | Window navigation.                        |
| n    | `<C-l>`            | Focus right split              | Built-in mapping     | 〃                                        |
| n    | `<C-j>`            | Focus lower split              | Built-in mapping     | 〃                                        |
| n    | `<C-k>`            | Focus upper split              | Built-in mapping     | 〃                                        |
| n    | `<leader>f`        | Format buffer                  | Conform              | Async; uses LSP or external tool.         |
| n    | `<leader>sh`       | Telescope: Help tags           | Telescope            | Search Neovim help.                       |
| n    | `<leader>sk`       | Telescope: Keymaps             | Telescope            | Browse all mappings.                      |
| n    | `<leader>sf`       | Telescope: Files               | Telescope            | Project file search.                      |
| n    | `<leader>ss`       | Telescope: Pickers             | Telescope            | List all pickers.                         |
| n    | `<leader>sw`       | Telescope: Word under cursor   | Telescope            | Grep current word.                        |
| n    | `<leader>sg`       | Telescope: Live Grep           | Telescope            | Ripgrep across project.                   |
| n    | `<leader>sd`       | Telescope: Diagnostics         | Telescope            | Search diagnostics.                       |
| n    | `<leader>sr`       | Telescope: Resume              | Telescope            | Reopen last picker.                       |
| n    | `<leader>s.`       | Telescope: Recent files        | Telescope            | Oldfiles picker.                          |
| n    | `<leader><leader>` | Telescope: Buffers             | Telescope            | Switch between open buffers.              |
| n    | `<leader>/`        | Fuzzy search in current buffer | Telescope (dropdown) | Quick in-buffer search.                   |
| n    | `<leader>s/`       | Live Grep in **open files**    | Telescope            | Narrow to visible buffers.                |
| n    | `<leader>sn`       | Find files in Neovim config    | Telescope            | Searches `stdpath('config')`.             |
| n    | `grn`              | LSP: Rename symbol             | LSP + Telescope      | Project-wide when supported.              |
| n/x  | `gra`              | LSP: Code Action               | LSP                  | Fixes / refactors.                        |
| n    | `grr`              | LSP: References                | LSP + Telescope      | Where is this used?                       |
| n    | `gri`              | LSP: Implementations           | LSP + Telescope      | Go to implementation.                     |
| n    | `grd`              | LSP: Definition                | LSP + Telescope      | Jump to definition. `<C-t>` to jump back. |
| n    | `grD`              | LSP: Declaration               | LSP                  | Header / decl site.                       |
| n    | `gO`               | LSP: Document symbols          | LSP + Telescope      | Functions, vars, etc. (file)              |
| n    | `gW`               | LSP: Workspace symbols         | LSP + Telescope      | Global symbol search.                     |
| n    | `grt`              | LSP: Type definition           | LSP + Telescope      | Jump to type.                             |
| n    | `<leader>th`       | Toggle LSP inlay hints         | LSP                  | Shows/hides type hints inline.            |
| n    | `<leader>mp`       | Preview for markdown           | Lazy/Glow            | open a preview for markdown               |
| n    | `<leader>mP`       | Preview for markdown split     | Lazy/Glow            | Opens a split preview                     |

## Folding Shortcuts (nvim-ufo)
===================================
| Shortcut | Action                                  |
| -------- | --------------------------------------- |
| `za`     | Toggle current fold                     |
| `zc`     | Close current fold                      |
| `zo`     | Open current fold                       |
| `zM`     | Close **all** folds                     |
| `zR`     | Open **all** folds                      |
| `zm`     | Close folds with a specific level       |
| `zr`     | Open folds except certain kinds         |
| `K`      | Peek folded lines (fallback: LSP hover) |

> You can always discover more Telescope keybinds **inside** a picker with `?` (normal mode) or `<C-/>` (insert mode).

## 11) How Things Load (under the hood)
===================================


- Many plugins are set to load on **`VimEnter`** or when their features are used—this keeps startup snappy.
- LSP keymaps are registered via an **`LspAttach` autocommand**, so they only exist in buffers where a language server is active.
- Mason ensures tools/servers exist but does not slow down editing; installations happen out-of-band.

## 12) Make It Yours
===================================


- Want Nerd Font icons? Set:

  ```lua
  vim.g.have_nerd_font = true
  ```

  This unlocks nicer symbols in `which-key`, diagnostics, and statusline.

- Add plugins by uncommenting:
  ```lua
  -- { import = 'custom.plugins' }
  ```
  and creating files in `lua/custom/plugins/`.

## 13) Troubleshooting
===================================

- `:checkhealth` — quick diagnostics if something seems off.
- If Telescope FZF native complains, ensure you have `make` available (it’s compiled on install).

## Appendix: What each major block looks like

- **Plugin list:** inside `require('lazy').setup({ ... }, { ui = { icons = ... } })`.
- **Telescope config & keymaps:** everything under `config = function() ... end` in the Telescope spec.
- **LSP config:** big `config = function()` for `nvim-lspconfig`, including servers, capabilities, on-attach keymaps, diagnostics UI, inlay hints toggle, and Mason integration.
- **Formatting:** `conform.nvim` has `opts` with `format_on_save` and a `<leader>f` mapping.
- **Treesitter:** `main = 'nvim-treesitter.configs'` with `opts` for `ensure_installed`, `highlight`, and `indent`.
