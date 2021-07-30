" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')
    " Better Syntax Support
    Plug 'leafoftree/vim-vue-plugin'
    Plug 'pangloss/vim-javascript'
    Plug 'vim-scripts/loremipsum'
    " Nerd Plugs
    Plug 'ryanoasis/vim-devicons'
    Plug 'scrooloose/NERDTree'
    Plug 'preservim/nerdcommenter'
    Plug 'wfxr/minimap.vim'
"
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'

    Plug 'luochen1990/rainbow'
    Plug 'yggdroot/indentline'
    " Fzf
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    Plug 'airblade/vim-rooter'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    Plug 'easymotion/vim-easymotion'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'dense-analysis/ale'
    "Plug 'mbbill/undotree'
    Plug 'APZelos/blamer.nvim'

    Plug 'airblade/vim-gitgutter'

    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    "themes
    Plug 'Rigellute/rigel' "rigel
    Plug 'altercation/vim-colors-solarized' "solarized
    Plug 'ayu-theme/ayu-vim' "ayu
    Plug 'cormacrelf/vim-colors-github' "Github
    Plug 'dracula/vim', { 'as': 'dracula' } "dracula
    Plug 'drewtempelmeyer/palenight.vim' "palenight
    Plug 'ghifarit53/tokyonight-vim'
    Plug 'joshdick/onedark.vim' "onedark
    Plug 'kyoz/purify', { 'rtp': 'vim' } "purify
    Plug 'lifepillar/vim-gruvbox8' "Gruvbox 8
    Plug 'mhartington/oceanic-next' "OceanicNext
    Plug 'sheldonldev/vim-gruvdark'

call plug#end()

