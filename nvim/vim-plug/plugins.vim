if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/autoload/plugged')
  Plug 'voldikss/vim-floaterm'
  Plug 'leafOfTree/vim-vue-plugin'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-pack/nvim-spectre'
  Plug 'github/copilot.vim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'airblade/vim-gitgutter'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'dense-analysis/ale'
  Plug 'easymotion/vim-easymotion'
  Plug 'jiangmiao/auto-pairs'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " Plug 'junegunn/vim-easy-align'
  Plug 'kdheepak/lazygit.nvim'
  Plug 'leafoftree/vim-matchtag'
  Plug 'machakann/vim-sandwich'
  Plug 'mhinz/vim-startify', { 'branch': 'center' }
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'preservim/nerdcommenter'
  Plug 'ryanoasis/vim-devicons'
  Plug 'scrooloose/NERDTree'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  Plug 'yaegassy/coc-volar', {'do': 'yarn install --frozen-lockfile'}

  " colorschemes
  Plug 'ayu-theme/ayu-vim'
  Plug 'glepnir/oceanic-material'
  Plug 'cocopon/iceberg.vim'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'joshdick/onedark.vim' "onedark
  Plug 'kyoz/purify', { 'rtp': 'vim' } "purify
  Plug 'larsbs/vimterial_dark'
  Plug 'morhetz/gruvbox'
  Plug 'patstockwell/vim-monokai-tasty'
  Plug 'rakr/vim-one'
  Plug 'ray-x/aurora'
  Plug 'sainnhe/sonokai'
  Plug 'sainnhe/vim-color-forest-night'
  Plug 'srcery-colors/srcery-vim'
  Plug 'NLKNguyen/papercolor-theme'
  Plug 'vim-scripts/Wombat'
call plug#end()
