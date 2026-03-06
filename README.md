# nvim config

Personal Neovim configuration, originally based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) but heavily extended over time. Focused on .NET/C#, TypeScript/Angular, and Lua development on macOS.

> [!NOTE]
> Only tested on macOS. YMMV on other platforms.

## Features

- **LSP** via `nvim-lspconfig` + Mason: C#, TypeScript, Angular, Lua, Terraform, PKL
- **Completion** via `blink.cmp` with AI completions (local Ollama via `minuet-ai`)
- **Formatting** via `conform.nvim`: `csharpier`, `stylua`, `prettierd`, `terraform fmt`
- **Debugging (DAP)**: deep .NET/C# support with custom build automation + JS/TS debugging
- **Testing**: `neotest` with `neotest-jest` and `neotest-dotnet`
- **Task running**: `overseer.nvim` with custom `dotnet run/build/test` templates
- **File explorer + UI**: `snacks.nvim` (explorer, dashboard, lazygit, notifications, indent guides)
- **Fuzzy finding**: Telescope
- **File bookmarks**: `grapple.nvim` (per-git-branch file tagging)
- **AI agent**: `opencode.nvim` connected to Amazon Bedrock / Claude Sonnet
- **Git**: `gitsigns.nvim` + lazygit via snacks

## Installation

### 1. Homebrew dependencies

```sh
brew install neovim ripgrep fd pkl-lsp prettier prettierd opencode make cmake
```

### 2. dotnet

Install via [the official install scripts](https://github.com/dotnet/install-scripts?tab=readme-ov-file) to support multiple runtimes side by side:

```sh
./dotnet-install.sh --version 10.0.101
./dotnet-install.sh --version 9.0.308
```

Add to `~/.zshrc`:

```sh
export DOTNET_ROOT="/Users/$USER/.dotnet"
export PATH="/Users/$USER/.dotnet:$PATH"
```

### 3. netcoredbg (DAP adapter for .NET, arm Mac)

```sh
cd ~/git
git clone https://github.com/Samsung/netcoredbg.git
cd netcoredbg
rm -rf build src/debug/netcoredbg/bin bin
mkdir build && cd build
CC=clang CXX=clang++ cmake ..
make
make install
```

The config expects the binary at `~/git/netcoredbg/build/src/netcoredbg`.

### 4. Clone and launch

```sh
git clone <your-repo-url> ~/.config/nvim
nvim
```

Lazy.nvim will bootstrap itself and install all plugins on first launch. Use `:Lazy` to check status.

### 5. Mason / DAP post-install

Inside Neovim, install the remaining tools that Mason doesn't handle automatically:

```
:MasonInstall angular-language-server
:MasonInstall typescript-language-server
:MasonInstall llm-ls
:DapInstall js
```

### Other notes

- A [Nerd Font](https://www.nerdfonts.com/) is required — set `vim.g.have_nerd_font = true` in `init.lua`
- opencode requires Amazon Bedrock credentials — see `opencode.example.json` for the config format

## Structure

```
~/.config/nvim/
├── init.lua                    # Options, global keymaps, lazy.nvim bootstrap
└── lua/
    ├── plugins/                # Plugin configs (auto-imported by lazy.nvim)
    ├── configs/
    │   ├── nvim-close-all.lua  # Close all panels (explorer, DAP UI, etc.)
    │   └── nvim-dap-dotnet.lua # .NET DAP: auto-build, launchSettings.json parsing
    ├── kickstart/
    │   ├── health.lua          # :checkhealth integration
    │   └── plugins/lint.lua    # nvim-lint (markdownlint)
    └── overseer/template/user/
        └── dotnet_run.lua      # Overseer task: dotnet run/build/test
```

## Key Mappings

Leader key: `<Space>`

### General

| Key           | Action                        |
| ------------- | ----------------------------- |
| `\`           | Toggle file explorer          |
| `<Esc>`       | Clear search highlight        |
| `<leader>q`   | Open diagnostic quickfix list |
| `<leader>xx`  | Close all panels              |
| `<C-h/j/k/l>` | Navigate splits               |

### LSP

| Key          | Action                    |
| ------------ | ------------------------- |
| `grn`        | Rename symbol             |
| `gra`        | Code action               |
| `grr`        | References                |
| `gri`        | Implementation            |
| `grd`        | Definition                |
| `gO`         | Document symbols          |
| `gW`         | Workspace symbols         |
| `grt`        | Type definition           |
| `<leader>xh` | Toggle inlay hints        |
| `gru`        | TS: Remove unused imports |
| `gro`        | TS: Organize imports      |
| `grO`        | TS: Add missing imports   |

### Find (`<leader>f`)

| Key                | Action                      |
| ------------------ | --------------------------- |
| `<leader>ff`       | Find files                  |
| `<leader>fg`       | Live grep                   |
| `<leader>fw`       | Grep word under cursor      |
| `<leader><leader>` | Find open buffers           |
| `<leader>fr`       | Resume last picker          |
| `<leader>f.`       | Recent files                |
| `<leader>ft`       | TODOs                       |
| `<leader>fc`       | Clipboard history           |
| `<leader>fm`       | Macro history               |
| `<leader>/`        | Fuzzy search current buffer |

### Debug (`<leader>d`)

| Key                    | Action                                                              |
| ---------------------- | ------------------------------------------------------------------- |
| `<leader>dc`           | Start / continue                                                    |
| `<leader>db`           | Toggle breakpoint                                                   |
| `<leader>dB`           | Conditional breakpoint                                              |
| `<leader>du`           | Toggle DAP UI                                                       |
| `<leader>de`           | Inspect variable                                                    |
| `<leader>dt`           | Terminate session                                                   |
| `<leader>dx`           | Clear all breakpoints                                               |
| `<Up/Down/Right/Left>` | Continue / Step over / Step into / Step out _(active session only)_ |

### Test (`<leader>t`)

| Key          | Action             |
| ------------ | ------------------ |
| `<leader>tr` | Run nearest test   |
| `<leader>tf` | Run file           |
| `<leader>tA` | Run all tests      |
| `<leader>td` | Debug nearest test |
| `<leader>ts` | Toggle summary     |
| `<leader>to` | Show output        |
| `<leader>tw` | Watch toggle       |

### Run / Tasks (`<leader>r`)

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>rv` | Toggle task list |
| `<leader>ra` | Run task         |
| `<leader>rt` | Task action      |
| `<leader>rs` | Shell            |

### Git (`<leader>h` / `<leader>g`)

| Key          | Action              |
| ------------ | ------------------- |
| `<leader>gg` | Open lazygit        |
| `]c` / `[c`  | Next / prev hunk    |
| `<leader>hs` | Stage hunk          |
| `<leader>hr` | Reset hunk          |
| `<leader>hb` | Blame line          |
| `<leader>hd` | Diff against index  |
| `<leader>xb` | Toggle inline blame |

### File Marks / Grapple (`<leader>m`)

| Key         | Action                     |
| ----------- | -------------------------- |
| `<leader>m` | Toggle tag on current file |
| `<leader>M` | Open tags window           |
| `<leader>n` | Next tag                   |
| `<leader>p` | Previous tag               |

### AI (`<leader>c`)

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>ca` | Ask opencode            |
| `<leader>cx` | Execute opencode action |
| `<C-,>`      | Toggle opencode panel   |
| `go`         | Add range to opencode   |

### Other

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>pp` | Format buffer        |
| `<leader>xn` | Notification history |
