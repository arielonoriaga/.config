#!/bin/bash
hyprctl binds -j | python3 -I -c '
import json, sys
MODS = [(64, "Super"), (1, "Shift"), (4, "Ctrl"), (8, "Alt")]
seen = set()
for b in json.load(sys.stdin):
    desc = b.get("description") or ""
    if not desc or b.get("submap"):
        continue
    keys = "+".join(name for bit, name in MODS if b["modmask"] & bit) or ""
    key = b["key"].replace("mouse:272", "Left drag").replace("mouse:273", "Right drag")
    combo = (keys + "+" + key) if keys else key
    line = f"{combo:<26}{desc}"
    if line not in seen:
        seen.add(line)
        print(line)
' | fuzzel --dmenu --prompt "shortcuts " --width 70 --lines 25 >/dev/null
