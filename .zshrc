ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit ice from"gh-r" 

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light romkatv/powerlevel10k
zinit light agkozak/zsh-z

autoload -U compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

pathadd() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

export BUN_INSTALL="$HOME/.bun"

# bun completions
[ -s "/home/ariel/.bun/_bun" ] && source "/home/ariel/.bun/_bun"

pathadd "/opt/nvim"
pathadd "$HOME/scripts"
pathadd "$PNPM_HOME"
pathadd "$HOME/.npm-global/bin"
pathadd "$HOME/go/bin"
pathadd "$HOME/.config/yarn/global/node_modules/.bin"
pathadd "$BUN_INSTALL/bin"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -f /home/ariel/.cache/pnpm/dlx/gjohq4w7nmxx2i3abs2heyqjpm/1948af4e31b-2dcb9/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /home/ariel/.cache/pnpm/dlx/gjohq4w7nmxx2i3abs2heyqjpm/1948af4e31b-2dcb9/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

get_cpu_temp() {
  temp=$(sensors | grep 'Package id 0' | awk '{print $4}')
  echo "${temp:1}"
}

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

function custom_cpu_temp {
  local temp=$(get_cpu_temp)
  if [[ -n $temp ]]; then
    echo "CPU: $temp°C"
  fi
}

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=('custom_cpu_temp')

ENABLE_CORRECTION="false"
ZSH_DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=2"
HIST_STAMPS="dd.mm.yyyy"

# vps
alias hostinger="cat ~/.passwords/hostinger | copy && ssh root@217.196.62.243"

#alias
alias cfg="v ~/.zshrc"
alias v="nvim"
alias copy="xclip -selection c"
alias deletebranchs="git branch --merged | grep -v '^*\smain$' | grep -v '^*\smaster$' | grep -v '^*\sdev$' | xargs git branch -d"
alias ds="docker stop $(docker ps -q)"
alias ld='lazydocker'
alias lg='lazygit'
alias neofolder="cd ~/.config && v"
alias o='open .'
alias open="browse"
alias p='cd ~/Projects/'
alias proyInit="npx license mit > LICENSE && npx gitignore node && git init && npm init -y"
alias pw='cd ~/Projects/Wizards/'
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias tree="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias wifipass="nmcli device wifi show-password"
alias bx="cd ~/Projects/black-box"
alias ls="ls --color"

# To customize prompt, run `p10k configure` or edit ~/.config/.p10k.zsh.
[[ ! -f ~/.config/.p10k.zsh ]] || source ~/.config/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
  startx
fi

# Where to save history
HISTFILE=~/.zsh_history
HISTSIZE=10000        # Commands stored in memory
SAVEHIST=10000        # Commands written to file

# Zsh options to manage history behavior
setopt HIST_IGNORE_ALL_DUPS      # Don’t record a command if it’s a duplicate
setopt HIST_REDUCE_BLANKS        # Remove superfluous spaces
setopt INC_APPEND_HISTORY        # Append commands as they are typed
setopt SHARE_HISTORY             # Share history across all sessions
setopt EXTENDED_HISTORY          # Timestamp each command
setopt HIST_SAVE_NO_DUPS         # When writing out history, don’t write duplicates
setopt HIST_FIND_NO_DUPS         # Don’t show duplicates in search
