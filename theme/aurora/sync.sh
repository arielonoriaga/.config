#!/usr/bin/env bash
set -uo pipefail

SHARED=(.config/quickshell .config/theme/aurora .config/waybar/style.css .config/mako .config/fuzzel .config/alacritty .config/hypr/hyprland.lua Pictures/Backgrounds)
VARIANTS_REL="Pictures/Backgrounds/aurora"
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=5)
SELF=".config/theme/aurora/sync.sh"

peer() {
  case "$(cat /etc/hostname)" in
    desktop-exo) echo laptop ;;
    *) echo desktop ;;
  esac
}

shared_files() {
  cd "$HOME" && find "${SHARED[@]}" -type f -not -path '*/__pycache__/*' -not -name '*.tmp.*' 2>/dev/null | LC_ALL=C sort
}

manifest() { cd "$HOME" && shared_files | xargs -d '\n' md5sum; }

fingerprint() { manifest | md5sum | cut -d' ' -f1; }

newest() { cd "$HOME" && { shared_files; find "${SHARED[@]}" -type d 2>/dev/null; } | xargs -d '\n' stat -c '%Y' | sort -n | tail -n1; }

only_in() { LC_ALL=C comm -23 <(printf '%s\n' "$1" | cut -c35- | LC_ALL=C sort) <(printf '%s\n' "$2" | cut -c35- | LC_ALL=C sort); }

remove() {
  local path
  while IFS= read -r path; do
    case "$path" in ''|/*|*..*) continue ;; esac
    for root in "${SHARED[@]}"; do
      [[ "$path" == "$root"/* || "$path" == "$root" ]] && rm -f -- "$HOME/$path" && break
    done
  done
  return 0
}

hypr_env() {
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] ||
    export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -n1)"
}

reload() {
  hypr_env
  "$HOME/.config/theme/aurora/palette.py" >/dev/null 2>&1
  pkill -USR2 -x waybar
  command -v makoctl >/dev/null && makoctl reload >/dev/null 2>&1
  return 0
}

receive() {
  local stage
  mkdir -p "$HOME/.cache/aurora"
  stage="$(mktemp -d "$HOME/.cache/aurora/incoming.XXXXXX")"
  tar -C "$stage" -xf - || { rm -rf "$stage"; return 1; }
  local paths
  paths="$(cd "$stage" && find . -type f -printf '%P\n')"
  printf '%s\n' "$paths" | while IFS= read -r path; do
    mkdir -p "$HOME/$(dirname "$path")"
    mv -f "$stage/$path" "$HOME/$path"
  done
  rm -rf "$stage"
  reload
  grep -q '^.config/quickshell/' <<<"$paths" && quickshell ipc call aurora reload >/dev/null 2>&1
  return 0
}

differing() { LC_ALL=C comm -23 <(printf '%s\n' "$1" | LC_ALL=C sort) <(printf '%s\n' "$2" | LC_ALL=C sort) | cut -c35-; }

reconcile() {
  local mine theirs remote_newest paths
  theirs="$("${SSH[@]}" "$(peer)" "$SELF manifest")" || exit 0
  mine="$(manifest)"
  [ "$mine" = "$theirs" ] && exit 0
  remote_newest="$("${SSH[@]}" "$(peer)" "$SELF newest")" || exit 0
  if [ "$(newest)" -ge "$remote_newest" ]; then
    only_in "$theirs" "$mine" | "${SSH[@]}" "$(peer)" "$SELF remove"
    paths="$(differing "$mine" "$theirs")"
    [ -n "$paths" ] || exit 0
    printf '%s\n' "$paths" | tar -C "$HOME" --ignore-failed-read -cf - -T - | "${SSH[@]}" "$(peer)" "$SELF receive"
  else
    only_in "$mine" "$theirs" | remove
    paths="$(differing "$theirs" "$mine")"
    [ -n "$paths" ] || exit 0
    printf '%s\n' "$paths" | "${SSH[@]}" "$(peer)" "$SELF pack-files" | receive
  fi
}

share_wallpaper() {
  local name="$1" stem="${1%-landscape.png}"
  tar -C "$HOME/$VARIANTS_REL" -cf - --ignore-failed-read "$name" "$stem-portrait.png" "$stem-landscape.led" 2>/dev/null |
    "${SSH[@]}" "$(peer)" "mkdir -p ~/$VARIANTS_REL && tar -C ~/$VARIANTS_REL -xf - && .config/theme/aurora/wallpaper.sh --apply $(printf %q "$name")"
}

case "${1:-reconcile}" in
  fingerprint) fingerprint ;;
  newest) newest ;;
  manifest) manifest ;;
  pack-files) tar -C "$HOME" --ignore-failed-read -cf - -T - ;;
  receive) receive ;;
  remove) remove ;;
  reload) reload ;;
  reconcile) reconcile ;;
  wallpaper) share_wallpaper "$2" ;;
  peer-wallpaper) "${SSH[@]}" "$(peer)" 'cat ~/.local/state/aurora/wallpaper 2>/dev/null' ;;
  current-wallpaper) cat "$HOME/.local/state/aurora/wallpaper" 2>/dev/null ;;
  *) echo "usage: sync.sh [reconcile|wallpaper <name>|fingerprint|newest|pack|reload|peer-wallpaper]" >&2; exit 64 ;;
esac
