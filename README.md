# Ariel's Development Environment Configuration

Modern development environment setup featuring Neovim with Lua configuration, Zsh with Oh My Zsh, and various development tools.

## Features

- **Neovim with Lazy.nvim**: Modern Neovim setup with fast plugin loading
- **High-Performance Completion**: Uses blink.cmp for lightning-fast completion
- **LSP Integration**: Full LSP support with Mason for easy language server management
- **AI-Powered Coding**: Supermaven AI completion + Claude Code integration
- **Rich UI**: Telescope, nvim-tree, lualine, and multiple colorschemes
- **Development Tools**: Git integration, fuzzy finding, find/replace, and more

## Installation Guide

### Prerequisites
```bash
sudo apt-get install git curl
```

### Clone and Setup
```bash
git clone git@github.com:arielonoriaga/.config.git
cd .config
chmod +x setup.sh
./setup.sh
```

### Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install Powerlevel10k Theme
1. Download [MesloFont (powerlevel10k)](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
2. Install the theme:
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Post-Installation
1. Restart your terminal
2. Run `p10k configure` to set up Powerlevel10k
3. Open Neovim and run `:checkhealth` to verify everything is working

## Key Components

- **Neovim**: Lua-based configuration with Lazy.nvim plugin manager
- **Zsh**: Enhanced shell with Oh My Zsh and Powerlevel10k
- **Git**: Integrated version control with LazyGit
- **LSP**: Language server support for multiple languages
- **AI Tools**: Supermaven + Claude Code for AI-assisted development

## Quick Start

After installation:
- Open Neovim: `nvim`
- File navigation: `Ctrl+U` (file tree), `;` (git files), `Ctrl+F` (grep search)
- Theme switching: `F4`
- Git operations: `<leader>lg` (LazyGit)
- AI completion: `Alt+F` (accept suggestion)

See `CLAUDE.md` for detailed keybindings and configuration information.
