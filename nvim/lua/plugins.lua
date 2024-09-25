-- Ensure packer.nvim is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
  end
end

ensure_packer()

-- Automatically run PackerSync after saving this file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use packer.nvim to manage plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager

  -- Terminal
  use 'voldikss/vim-floaterm'

  -- Utility Plugins
  use 'nvim-pack/nvim-spectre'

  -- Copilot (AI-assisted coding)
  use 'github/copilot.vim'

  -- Treesitter for better syntax highlighting and parsing
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  -- Git integration
  use 'airblade/vim-gitgutter'
  use 'kdheepak/lazygit.nvim'
  use 'tpope/vim-fugitive'

  -- Navigation
  use 'christoomey/vim-tmux-navigator'
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'
  use 'nvim-tree/nvim-tree.lua'

  use 'nvim-lua/plenary.nvim'
  use 'zaldih/themery.nvim'

  -- Go development
  use {'fatih/vim-go', run = ':GoUpdateBinaries'}

  -- Autocompletion and LSP integration
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'yaegassy/coc-volar'

  -- Pairs management
  use 'jiangmiao/auto-pairs'

  -- Better tag matching
  use 'leafoftree/vim-matchtag'
  use 'machakann/vim-sandwich'

  -- Commenting
  use 'preservim/nerdcommenter'
  use 'numToStr/Comment.nvim'

  -- File Explorer
  use 'kyazdani42/nvim-tree.lua'

  -- Statusline
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'

  -- Colorschemes
  use 'ayu-theme/ayu-vim'
  use 'glepnir/oceanic-material'
  use 'cocopon/iceberg.vim'
  use 'ghifarit53/tokyonight-vim'
  use 'joshdick/onedark.vim'
  use 'kyoz/purify'
  use 'larsbs/vimterial_dark'
  use 'morhetz/gruvbox'
  use 'sainnhe/everforest'
  use 'patstockwell/vim-monokai-tasty'
  use 'rakr/vim-one'
  use 'ray-x/aurora'
  use 'sainnhe/sonokai'
  use 'srcery-colors/srcery-vim'
  use 'NLKNguyen/papercolor-theme'
  use 'vim-scripts/Wombat'
  use "yorumicolors/yorumi.nvim"

  -- Optional: Speed up loading time
  use 'lewis6991/impatient.nvim'
end)
