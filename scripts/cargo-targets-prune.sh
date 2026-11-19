#!/usr/bin/env bash
# Prune per-branch cargo target caches that have gone quiet.
#
# Guards BOTH caches. There are two by construction: ~/.cargo/config.toml sets
# target-dir to /var/cache/cargo-builds/cargo-targets, and agents additionally
# set CARGO_TARGET_DIR per branch. The old unit watched only the home one and
# missed 189 of the 329 GB that had piled up by 2026-08-23.
#
# Age is measured INSIDE each dir, never by the dir's own mtime: that mtime
# only moves when top-level entries change, so ~/.cache/cargo-targets/main read
# as 4 days idle while cargo was writing into it the same evening. A naive
# `-mtime +N` on the directory would delete a live cache.
set -uo pipefail

DAYS="${CARGO_PRUNE_DAYS:-3}"
DRY="${DRY_RUN:-0}"

# debug/ and release/ are cargo's own profile dirs for the shared target-dir —
# the live build output, not per-branch leftovers.
prune_root() {
  local root=$1; shift
  local keep=("$@")
  [[ -d $root ]] || return 0
  for dir in "$root"/*/; do
    [[ -d $dir ]] || continue
    local name; name=$(basename "$dir")
    for k in "${keep[@]}"; do [[ $name == "$k" ]] && continue 2; done
    # -mmin, not -newermt: `find` here is bfs, which rejects `-newermt "-3
    # days"` as an invalid timestamp. It failed SILENTLY — the dir then read as
    # idle and would have been deleted, live caches included. -mmin is accepted
    # by both bfs and GNU findutils.
    #
    # -quit stops at the first recent file: cheap for active dirs, which is the
    # common case; only genuinely stale trees get walked in full.
    local recent rc
    recent=$(find "$dir" -mmin "-$((DAYS * 1440))" -print -quit 2>/dev/null); rc=$?
    # A find that errors must never read as "idle" — that is the failure mode
    # that deletes live work. Unknown ⇒ keep.
    if (( rc != 0 )) || [[ -n $recent ]]; then
      continue
    fi
    local sz; sz=$(du -sm "$dir" 2>/dev/null | cut -f1)
    if [[ $DRY == 1 ]]; then
      echo "would remove ${sz}MB  $dir"
    else
      echo "removing ${sz}MB  $dir"
      rm -rf "$dir"
    fi
  done
}

prune_root "$HOME/.cache/cargo-targets"
prune_root /var/cache/cargo-builds/cargo-targets debug release
