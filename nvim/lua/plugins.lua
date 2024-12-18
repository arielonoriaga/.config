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

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Terminal
  use 'voldikss/vim-floaterm'

  -- Utility Plugins
  use 'nvim-pack/nvim-spectre'

  -- use {
    -- 'sphamba/smear-cursor.nvim',
    -- opts = {},
  -- }

  -- Copilot (AI-assisted coding)
  use 'github/copilot.vim'

  use 'nvim-tree/nvim-web-devicons'
  -- Treesitter for better syntax highlighting and parsing
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }

  -- Git integration
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        current_line_blame_opts = {
          delay = 500,
        },
        current_line_blame = true,
        numhl = true,
      }
    end
  }

  use {
    'folke/which-key.nvim',
    lazy = true,
    opts = {},
  }

  use 'kdheepak/lazygit.nvim'
  -- use 'tpope/vim-fugitive'

  -- Navigation
  use 'christoomey/vim-tmux-navigator'

  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use 'nvim-tree/nvim-tree.lua'

  use { 'p00f/nvim-ts-rainbow' }
  use { 'nvim-treesitter/nvim-treesitter-context' }

  -- Pairs management
  use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
        require('nvim-autopairs').setup {}
    end
  }

  use {
    'romgrk/barbar.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }

  use 'jose-elias-alvarez/null-ls.nvim'

  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig'
  }

  use { "glepnir/lspsaga.nvim" }
  -- use { "j-hui/fidget.nvim", tag = "legacy" }
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip', -- Snippets plugin
      'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
    }
  }

  -- Commenting
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  -- Better tag matching
  use 'leafoftree/vim-matchtag'
  use 'machakann/vim-sandwich'

  -- use 'xiyaowong/transparent.nvim'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use 'atiladefreitas/dooing'

  use {
    'startup-nvim/startup.nvim',
    requires = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim'
    },
    config = function()
      require'startup'.setup()
    end
  }

  -- colorscheme picker
  use 'zaldih/themery.nvim'

  -- Colorschemes
  use 'ayu-theme/ayu-vim'
  use 'joshdick/onedark.vim'
  use 'larsbs/vimterial_dark'
  use 'morhetz/gruvbox'
  use 'sainnhe/everforest'
  use 'patstockwell/vim-monokai-tasty'
  use 'sainnhe/gruvbox-material'

  -- Optional: Speed up loading time
  use 'lewis6991/impatient.nvim'
end)
