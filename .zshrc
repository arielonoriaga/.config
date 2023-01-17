if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ -f /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export PATH="$(yarn global bin):$PATH"
export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export ZSH="/home/ariel/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="false"

plugins=(
git
zsh-autosuggestions
zsh-syntax-highlighting
fzf-tab
)

source $ZSH/oh-my-zsh.sh

ZSH_DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=2"
HIST_STAMPS="dd.mm.yyyy"

# vps
alias aruze="cat ~/.passwords/aruze | copy && ssh root@159.89.148.250"
alias wizards="cat ~/.passwords/wizards | copy && ssh root@161.35.117.69"
alias intersea="cat ~/.passwords/intersea | copy && ssh root@api.seaong.ar"

#vpn
alias sdgitlab="cat ~/.passwords/sdbranch | copy && fortivpn connect acumera -u aonoriaga"

#alias
alias cfg="v ~/.zshrc"
alias copy="xclip -selection c"
alias deletebranchs="git branch --merged | grep -v '^*\smain$' | grep -v '^*\smaster$' | grep -v '^*\sdev$' | xargs git branch -d"
alias ds="docker stop $(docker ps -q)"
alias fortivpn="/opt/forticlient/fortivpn"
alias ld='lazydocker'
alias lg='lazygit'
alias neofolder="~/.config && v"
alias o='open .'
alias open="browse"
alias p='~/Projects/'
alias proyInit="npx license mit > LICENSE && npx gitignore node && git init && npm init -y"
alias pw='~/Projects/Wizards/'
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias tree="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias v="nvim"
alias wifipass="nmcli device wifi show-password"
