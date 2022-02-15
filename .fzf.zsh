# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ariel/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/ariel/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/ariel/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/ariel/fzf/shell/key-bindings.zsh"
