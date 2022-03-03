if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/autoload/plugged')
  Plug 'APZelos/blamer.nvim'
  Plug 'airblade/vim-gitgutter'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'dense-analysis/ale'
  Plug 'easymotion/vim-easymotion'
  Plug 'jiangmiao/auto-pairs'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'kdheepak/lazygit.nvim'
  Plug 'leafoftree/vim-matchtag'
  Plug 'leafoftree/vim-vue-plugin'
  Plug 'machakann/vim-sandwich'
  Plug 'mhinz/vim-startify', { 'branch': 'center' }
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'pangloss/vim-javascript'
  Plug 'preservim/nerdcommenter'
  Plug 'ryanoasis/vim-devicons'
  Plug 'sainnhe/vim-color-forest-night'
  Plug 'scrooloose/NERDTree'
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'yaegassy/coc-volar', {'do': 'yarn install --frozen-lockfile'}

  " colorschemes
  Plug 'cocopon/iceberg.vim'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'joshdick/onedark.vim' "onedark
  Plug 'kyoz/purify', { 'rtp': 'vim' } "purify
  Plug 'larsbs/vimterial_dark'
  Plug 'morhetz/gruvbox'
  Plug 'patstockwell/vim-monokai-tasty'
  Plug 'rakr/vim-one'
  Plug 'sainnhe/sonokai'
  Plug 'srcery-colors/srcery-vim'
  Plug 'vim-scripts/Wombat'
call plug#end()
