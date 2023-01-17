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
#
source "/usr/share/doc/fzf/examples/key-bindings.zsh"
