#!/usr/bin/env bash

search_dir=(
    # Add serached directories
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    paths="$(printf "%s\n" "${search_dir[@]}")"$'\n'
    paths+="$(fd --type d -d 3 $(printf " --search-path %s" "${search_dir[@]}"))"
    selected=$(echo "$paths" | fzf --reverse --prompt="Select directory: " --height=16 --scheme=path +m)
fi

if [[ -z $selected ]]; then
    exit 0
fi

child_folder=$(basename "$selected")
parent_folder=$(basename $(dirname "$selected"))

# selected_name=$(basename "$selected" | tr . _)
selected_name=$(echo "$parent_folder~$child_folder" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

if [[ -z $TMUX ]]; then
    tmux attach -t $selected_name
else
    tmux switch-client -t $selected_name
fi
