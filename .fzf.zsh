# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ariel/temporals/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/ariel/temporals/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/ariel/temporals/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
# source "/home/ariel/temporals/fzf/shell/key-bindings.zsh"
