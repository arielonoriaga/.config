" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')
    Plug 'APZelos/blamer.nvim'
    Plug 'Rigellute/rigel' "rigel
    Plug 'airblade/vim-gitgutter'
    Plug 'altercation/vim-colors-solarized' "solarized
    Plug 'ayu-theme/ayu-vim' "ayu
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'cormacrelf/vim-colors-github' "Github
    Plug 'dense-analysis/ale'
    Plug 'dracula/vim', { 'as': 'dracula' } "dracula
    Plug 'drewtempelmeyer/palenight.vim' "palenight
    Plug 'easymotion/vim-easymotion'
    Plug 'ghifarit53/tokyonight-vim'
    Plug 'jiangmiao/auto-pairs'
    Plug 'joshdick/onedark.vim' "onedark
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'kyoz/purify', { 'rtp': 'vim' } "purify
    Plug 'larsbs/vimterial_dark'
    Plug 'leafoftree/vim-vue-plugin'
    Plug 'lifepillar/vim-gruvbox8' "Gruvbox 8
    Plug 'machakann/vim-sandwich'
    Plug 'mhartington/oceanic-next' "OceanicNext
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'othree/javascript-libraries-syntax.vim'
    Plug 'pangloss/vim-javascript'
    Plug 'preservim/nerdcommenter'
    Plug 'rakr/vim-one'
    Plug 'sainnhe/sonokai'
    Plug 'sainnhe/vim-color-forest-night'
    Plug 'scrooloose/NERDTree'
    Plug 'scwood/vim-hybrid'
    Plug 'sheldonldev/vim-gruvdark'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'wfxr/minimap.vim'
    Plug 'yggdroot/indentline'
    Plug 'SirVer/ultisnips'
    Plug 'mlaursen/vim-react-snippets'
    Plug 'yaegassy/coc-volar', {'do': 'yarn install --frozen-lockfile'}
call plug#end()
