if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/arielonoriaga/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="false"

plugins=(git)

source $ZSH/oh-my-zsh.sh
ZSH_DISABLE_COMPFIX="true"

alias gplb='git pull origin `git branch --show-current`'
alias deletebranchs="git branch --merged | grep -v '^* master$' | grep -v '^ master$' | xargs git branch -d"
alias tree="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias laravel="~/.config/composer/vendor/bin/laravel"
alias gpfb='git push -f'
alias gpm='git push origin master'
alias gplo='git pull origin master'
alias ntst='~/Projects/Picallex/picallex && npm run test:unit'
alias nftst="~/Projects/Picallex/picallex && npm run test:full-suite"
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias dtst="~/Projects/Picallex/ && make pcx7-npm-test-unit"
alias dftst="~/Projects/Picallex/ && make pcx7-npm-test-full"
alias cfg="nvim ~/.zshrc"
alias startpcx="~/Projects/Picallex/ && make up"
alias watchpcx="~/Projects/Picallex/ && make pcx7-watch"
alias stoppcx="~/Projects/Picallex/ && make stop"
alias xamppfolder="~/.bitnami/stackman/machines/xampp/volumes/root/htdocs"
alias o='open .'
alias vcfg="v ~/.vimrc"
alias vimfolder="~/.vim/ && v"
alias neofolder="~/.config/nvim/ && v"
alias lint="~/Projects/Picallex/picallex && npm run lint:fix"
alias reloadv="source ~/.vimrc"
alias v="nvim"
alias vpicallex="~/Projects/Picallex/picallex && v"
alias dcm="git reset HEAD~1"
alias opcoverage="open ~/Projects/Picallex/picallex/coverage/index.html"

alias vreservas="~/Projects/app-reservas-web && v"

export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export PATH="/usr/local/opt/ruby/bin:$PATH"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -f /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh
