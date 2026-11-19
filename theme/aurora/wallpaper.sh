#!/bin/bash
set -u
DIR="$HOME/.config/theme/aurora"
VARIANTS="$HOME/Pictures/Backgrounds/aurora"
STATE="$HOME/.local/state/aurora"
MODE="${1:-shuffle}"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] ||
  export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -n1)"

LANDSCAPE="$DIR/wallpaper-landscape.png"
PORTRAIT="$DIR/wallpaper-portrait.png"
CURRENT=$(hyprctl hyprpaper listactive 2>/dev/null | sed -n 's/^[^:]*: //p' | grep -- '-landscape.png$' | head -n 1)

case "$MODE" in
  --apply) PICK="$VARIANTS/${2:-}" ;;
  --login) PEER_PICK=$("$DIR/sync.sh" peer-wallpaper)
           PICK=${PEER_PICK:+$VARIANTS/$PEER_PICK} ;;
  *) PICK="" ;;
esac
if [ -z "$PICK" ] || [ ! -f "$PICK" ]; then
  PICK=$(find "$VARIANTS" -name '*-landscape.png' 2>/dev/null | grep -vxF -- "$CURRENT" | shuf -n 1)
  [ "$MODE" = "--apply" ] && exit 0
  [ "$MODE" = "--login" ] && MODE=shuffle
fi
if [ -n "$PICK" ] && [ -f "${PICK%-landscape.png}-portrait.png" ]; then
  LANDSCAPE="$PICK"
  PORTRAIT="${PICK%-landscape.png}-portrait.png"
fi

pgrep -x hyprpaper >/dev/null 2>&1 || { hyprpaper >/dev/null 2>&1 & sleep 1; }
hyprctl monitors -j | python3 -I -c 'import json, sys; [print(m["name"], m["transform"] % 2) for m in json.load(sys.stdin)]' |
while read -r monitor rotated; do
  if [ "$rotated" = 1 ]; then image="$PORTRAIT"; else image="$LANDSCAPE"; fi
  hyprctl hyprpaper wallpaper "$monitor,$image" >/dev/null
done
mkdir -p "$STATE"
basename "$LANDSCAPE" > "$STATE/wallpaper"
"$DIR/palette.py" "$LANDSCAPE" >/dev/null && pkill -USR2 -x waybar
[ "$MODE" = "shuffle" ] && [ "$LANDSCAPE" != "$DIR/wallpaper-landscape.png" ] && "$DIR/sync.sh" wallpaper "$(basename "$LANDSCAPE")" &
[ -x "$HOME/.config/scripts/rgb-from-wallpaper.py" ] && "$HOME/.config/scripts/rgb-from-wallpaper.py" "$LANDSCAPE" &
wait
