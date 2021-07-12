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

    " Nerd Plugs
    Plug 'scrooloose/NERDTree'
    "Plug 'preservim/nerdcommenter'

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
    Plug 'sonph/onehalf', { 'rtp': 'vim' } "onehalf
    Plug 'drewtempelmeyer/palenight.vim' "palenight
    Plug 'mhartington/oceanic-next' "OceanicNext
    Plug 'morhetz/gruvbox' "Gruvbox
    Plug 'altercation/vim-colors-solarized' "solarized
    Plug 'joshdick/onedark.vim' "onedark
    Plug 'kyoz/purify', { 'rtp': 'vim' } "purify
    Plug 'ayu-theme/ayu-vim' "ayu
    "no airline themes
        Plug 'dracula/vim', { 'as': 'dracula' } "dracula

call plug#end()

