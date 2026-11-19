#!/usr/bin/env bash
set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}"
host="$(cat /proc/sys/kernel/hostname)"
host_dir="$config/hosts/$host"
[ -d "$host_dir" ] || { echo "no host files for $host in $host_dir" >&2; exit 1; }

link_one() {
  local relative="$1" source="$host_dir/$1" target="$config/$1"
  [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ] && return
  if [ -f "$target" ] && [ ! -L "$target" ] && ! cmp -s "$target" "$source"; then
    mv "$target" "$target.pre-host-link"
    echo "kept the old $relative as $relative.pre-host-link"
  fi
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  echo "linked $relative"
}

cd "$host_dir"
find . -type f -printf '%P\n' | while IFS= read -r relative; do link_one "$relative"; done
