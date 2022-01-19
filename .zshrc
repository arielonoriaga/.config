if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="/Users/arielonoriaga/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="false"

plugins=(git)

source $ZSH/oh-my-zsh.sh
ZSH_DISABLE_COMPFIX="true"

alias cfg="nvim ~/.zshrc"
alias dcm="git reset HEAD~1"
alias deletebranchs="git branch --merged | grep -v '^*\smain$' | grep -v '^*\smaster$' | xargs git branch -d"
alias ggum="git pull --rebase origin master"
alias gpfb='git push -f'
alias gplb='git pull origin `git branch --show-current`'
alias gplo='git pull origin master'
alias gpm='git push origin master'
alias laravel="~/.config/composer/vendor/bin/laravel"
alias lint="pcx && gwip && npm run lint:fix && gunwip"
alias neofolder="~/.config/nvim/ && v"
alias nftst="~/Projects/Picallex/picallex && npm run test:full-suite"
alias npmPcxReset="pcx && rm -Rf node_modules/ dist/ && npm i --only=prod; npm run prod"
alias ntst='~/Projects/Picallex/picallex && npm run test:unit'
alias o='open .'
alias p='~/Projects/'
alias opcoverage="open ~/Projects/Picallex/picallex/coverage/index.html"
alias pcx="~/Projects/Picallex/picallex/"
alias proyInit="npx license mit > LICENSE && npx gitignore node && git init && npm init -y"
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias startpcx="~/Projects/Picallex/ && make up"
alias stoppcx="~/Projects/Picallex/ && make stop"
alias tree="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias v="nvim"
alias vcfg="v ~/.vimrc"
alias vimfolder="~/.vim/ && v"
alias wpcx="pcx && npm run watch"
alias xamppfolder="~/.bitnami/stackman/machines/xampp/volumes/root/htdocs"
alias gcmg="commit"

function commit () {
    echo $1 | commitlint

    my_branch=($(git rev-parse --abbrev-ref HEAD | tr '_' '\n'))

    project=$my_branch[2]
    issueKey=$my_branch[1]

    commit="$project-$issueKey | $1"

    (git commit -m $commit)
}

export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export PATH="/usr/local/opt/ruby/bin:$PATH"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -f /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh
