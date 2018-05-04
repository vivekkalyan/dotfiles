SESSION_NAME=$(basename "$(pwd)")
if tmux has-session -t "$SESSION_NAME" 2> /dev/null; then
  tmux attach -t "$SESSION_NAME"
  exit
fi

# Create session
tmux new-session -d -s "$SESSION_NAME" -n zsh 

# 1. Main Window
tmux send-keys -t "$SESSION_NAME":zsh "clear" Enter
tmux send-keys -t "$SESSION_NAME":zsh "ll" Enter
tmux split-window -t "$SESSION_NAME":zsh -h 
tmux send-keys -t "$SESSION_NAME":zsh "clear" Enter
tmux send-keys -t "$SESSION_NAME":zsh.right "g s" Enter

# 2. Vim
tmux new-window -t "$SESSION_NAME" -n vim
tmux send-keys -t "$SESSION_NAME":vim "vim" Enter
tmux send-keys -t "$SESSION_NAME":vim ",k" Enter

# Attach to session
tmux attach -t "$SESSION_NAME":zsh.left
