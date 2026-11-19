if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" = "1" ]; then
  exec hyprland
fi

# Auto-start tmux first — don't pay for a config the exec throws away
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

# p10k instant prompt — must stay at the top, paints the prompt before plugins load
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Optimize compinit - only rebuild once per day
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-${HOME}}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d ${ZDOTDIR:-${HOME}}/.zcompdump
else
  compinit -C -d ${ZDOTDIR:-${HOME}}/.zcompdump
fi

# Load plugins with async/defer for better performance
zinit ice lucid wait'0'
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait'0'
zinit light zsh-users/zsh-completions

zinit ice lucid wait'0'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait'0'
zinit light Aloxaf/fzf-tab

zinit light romkatv/powerlevel10k

zinit ice lucid wait'0'
zinit light agkozak/zsh-z

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Optimized path addition function
pathadd() {
  [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

export BUN_INSTALL="$HOME/.bun"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

pathadd "/opt/nvim"
pathadd "$HOME/.config/scripts"
pathadd "$HOME/.npm-global/bin"
pathadd "$HOME/.local/bin"
pathadd "$HOME/.config/yarn/global/node_modules/.bin"
pathadd "$BUN_INSTALL/bin"

export PATH=$PATH:/usr/local/go/bin

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

ENABLE_CORRECTION="false"
ZSH_DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=2"
HIST_STAMPS="dd.mm.yyyy"

# vps - lazy load password function
hostinger() {
  cat ~/.passwords/hostinger | copy && ssh root@217.196.62.243
}

#alias
alias cfg="v ~/.zshrc"
alias v="nvim"
alias copy="wl-copy"
alias deletebranchs="git branch --merged | grep -v '^*\smain$' | grep -v '^*\smaster$' | grep -v '^*\sdev$' | xargs git branch -d"
# alias ds="docker stop $(docker ps -q)"
alias ld='lazydocker'
alias lg='lazygit'
alias neofolder="cd ~/.config && v"
alias o='open .'
alias open="browse"
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias tree="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias wifipass="nmcli device wifi show-password"
alias ls="ls --color -la"
alias cc="claude --dangerously-skip-permissions"
alias nvidia-run="__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia"
alias cci="~/.claude/hooks/improve/queue.sh browse"
alias lzm="lazy-multi-gm"

# Lazy load NVM to improve startup time
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f node
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

# Where to save history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Zsh options to manage history behavior
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

export EDITOR=nvim

setopt COMPLETE_ALIASES
export PATH="$HOME/Desktop/custom-cli:$PATH"

# OpenClaw Completion
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"

# opencode
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"
[ -f ~/.secrets.zsh ] && source ~/.secrets.zsh  # keys live outside git

# cycle all swap (swapon -a is fstab-only, misses zram) — use instead of `swapoff -a && swapon -a`
reswap() {
  sudo swapoff -a
  sudo systemctl restart systemd-zram-setup@zram0.service  # zram (not in fstab)
  sudo swapon -a                                           # /swapfile from fstab
  swapon --show
}

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Rust build cache — moved to NVMe, see system-tune.sh
if [ -d /var/cache/cargo-builds ]; then
  export SCCACHE_DIR=/var/cache/cargo-builds/sccache
  export SCCACHE_CACHE_SIZE=50G
fi