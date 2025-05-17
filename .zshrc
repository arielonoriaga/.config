# [ -d "$HOME/Library/Android/sdk" ] && ANDROID_HOME=$HOME/Library/Android/sdk || ANDROID_HOME=$HOME/Android/Sdk

export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:$HOME/scripts"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# pnpm
export PNPM_HOME="/home/ariel/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ -f /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/arielonoriaga/.npm-global/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh

get_cpu_temp() {
    # Get the CPU temperature using `sensors`, and extract the temperature value
    temp=$(sensors | grep 'Package id 0' | awk '{print $4}')
    # Trim the '+' character if present
    echo "${temp:1}"
}

# JAVA_HOME="/usr/lib/java"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java"
# export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
# export ANDROID_HOME=$ANDROID_HOME
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
# export PATH="$(yarn global bin):$PATH"
export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
# export PATH="/usr/bin/android-studio:$PATH"
export PATH="$PATH:$JAVA_HOME/bin"
export PATH=~/.npm-global/bin:$PATH
export PATH="/home/ariel/go/bin:$PATH"
export ZSH="/home/ariel/.oh-my-zsh"

# PATH=$PATH:$ANDROID_SDK_ROOT/tools
# PATH=$PATH:$ANDROID_SDK_ROOT/platform-toolsexport
GOBIN=$HOME/go/bin

ZSH_THEME="powerlevel10k/powerlevel10k"

function custom_cpu_temp {
    local temp=$(get_cpu_temp)
    # Check if temp is not empty and create the output format
    if [[ -n $temp ]]; then
        echo "CPU: $temp°C"
    fi
}

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=('custom_cpu_temp')

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
alias phoenix-ssh="ssh -i ~/.ssh/phoenix-dagg.pem ec2-user@phoenix.sixthrock.network"
alias hostinger="cat ~/.passwords/hostinger | copy && ssh root@217.196.62.243"

#vpn
alias sdgitlab="cat ~/.passwords/sdbranch | copy && fortivpn connect acumera -u aonoriaga"

#alias
alias cfg="v ~/.zshrc"
alias v="nvim"
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
alias wifipass="nmcli device wifi show-password"
alias bx="cd ~/Projects/black-box"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# bun completions
[ -s "/home/ariel/.bun/_bun" ] && source "/home/ariel/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.config/.p10k.zsh.
[[ ! -f ~/.config/.p10k.zsh ]] || source ~/.config/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
  startx
fi

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /home/ariel/.cache/pnpm/dlx/gjohq4w7nmxx2i3abs2heyqjpm/1948af4e31b-2dcb9/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /home/ariel/.cache/pnpm/dlx/gjohq4w7nmxx2i3abs2heyqjpm/1948af4e31b-2dcb9/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh
