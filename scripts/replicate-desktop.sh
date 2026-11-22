#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="${IRON_GH_USER:-arielonoriaga}"
DOTCONFIG_HTTP="https://github.com/${GITHUB_USER}/.config.git"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
LOCAL_BIN="$HOME/.local/bin"
CARGO_TARGET_BASE="${CARGO_TARGET_BASE:-$HOME/.cache/cargo-targets}"

MODE="full"
ASSUME_YES=0
CHECK_ONLY=0
SKIP_GUI=0

usage() {
  cat <<'EOF'
Usage: replicate-desktop.sh [options]

One-command workstation & Iron Stack replicator for Arch Linux (and --ai-only on any Linux).

Bootstrap from a fresh install:
  curl -fsSL https://raw.githubusercontent.com/arielonoriaga/.config/master/scripts/replicate-desktop.sh | bash -s -- --yes

Options:
  --check, --dry-run  Inspect current machine readiness without modifying anything
  --ai-only           Install/wire only Dev Toolchains + Security CLI + Claude Harness + Iron Stack
  --skip-gui          Skip Hyprland/Wayland/GPU GUI packages; install CLI + Dev + Iron Stack
  --yes, -y           Non-interactive mode (no confirmation prompts)
  --help, -h          Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check|--dry-run) CHECK_ONLY=1 ;;
    --ai-only) MODE="ai-only"; SKIP_GUI=1 ;;
    --skip-gui) SKIP_GUI=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "Refusing to run as root; invoke as your normal user (sudo is requested only when needed)." >&2
  exit 1
fi

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$*"; }

ensure_path() {
  local d
  for d in "$LOCAL_BIN" "$HOME/.cargo/bin" "$HOME/.bun/bin" "$HOME/.local/share/pnpm/bin" "$HOME/.config/scripts"; do
    [[ -d "$d" ]] && [[ ":$PATH:" != *":$d:"* ]] && PATH="$d:$PATH"
  done
  export PATH
}

check_group() {
  local label="$1"
  shift
  log "$label"
  local cmd
  for cmd in "$@"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      ok "$cmd -> $(command -v "$cmd")"
    else
      warn "$cmd missing"
    fi
  done
}

check_status() {
  ensure_path
  log "Auditing workstation & Iron Stack readiness on $(uname -n)..."

  check_group "Core CLI" git zsh tmux nvim rg fd fzf jq duckdb shellcheck gh tailscale docker
  check_group "Toolchains" rustup cargo sccache bun uv node python3
  check_group "Security Arsenal" gitleaks osv-scanner zizmor semgrep actionlint ast-grep cargo-audit cargo-deny trivy hadolint yq rbw
  check_group "AI & Iron Stack" claude iron fallow hyperfine sd xh

  log "Repositories & Memory Vaults"
  local path
  for path in \
    "$HOME/.config/.git" \
    "$HOME/.claude/.git" \
    "$PROJECTS_DIR/iron-suite/.git" \
    "$HOME/.local/share/iron/git-vault/.git" \
    "$HOME/.local/share/iron/memory.db" \
    "$PROJECTS_DIR/entropy-hunter/.git" \
    "$PROJECTS_DIR/notes/.git"; do
    if [[ -e "$path" ]]; then
      ok "$path present"
    else
      warn "$path not initialized yet"
    fi
  done

  log "Systemd User Timers"
  if command -v systemctl >/dev/null 2>&1; then
    local unit
    for unit in iron-memory-refresh.timer iron-memory-backup.timer secrets-materialize.timer claude-relearn.timer; do
      if systemctl --user is-enabled "$unit" >/dev/null 2>&1; then
        ok "$unit enabled"
      else
        warn "$unit not enabled"
      fi
    done
  fi
}

can_access_private_github() {
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    return 0
  fi
  ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@personal 2>&1 | grep -qi "successfully authenticated" && return 0
  ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com 2>&1 | grep -qi "successfully authenticated" && return 0
  return 1
}

clone_or_pull_repo() {
  local repo_name="$1" dest="$2" visibility="${3:-public}"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only -q || warn "Could not fast-forward $dest (dirty or diverged; preserved as-is)"
    ok "$repo_name up to date ($dest)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ "$visibility" == "private" ]] && ! can_access_private_github; then
    warn "Skipping private repo ${GITHUB_USER}/${repo_name}: authenticate first via 'gh auth login' or SSH key, then re-run."
    return 1
  fi
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh repo clone "${GITHUB_USER}/${repo_name}" "$dest" -- --quiet
  elif ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@personal 2>&1 | grep -qi "successfully authenticated"; then
    git clone -q "git@personal:${GITHUB_USER}/${repo_name}.git" "$dest"
  else
    git clone -q "https://github.com/${GITHUB_USER}/${repo_name}.git" "$dest"
  fi
  ok "Cloned ${GITHUB_USER}/${repo_name} -> $dest"
}

bootstrap_dotconfig() {
  log "Syncing $HOME/.config dotfiles repository..."
  mkdir -p "$HOME/.config" "$LOCAL_BIN"
  if [[ ! -d "$HOME/.config/.git" ]]; then
    local backup_dir
    backup_dir="$HOME/.config-pre-replicate-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir"
    git -C "$HOME/.config" init -q
    git -C "$HOME/.config" remote add origin "$DOTCONFIG_HTTP"
    git -C "$HOME/.config" fetch -q --depth=1 origin master
    while IFS= read -r tracked; do
      if [[ -e "$HOME/.config/$tracked" && ! -L "$HOME/.config/$tracked" ]]; then
        mkdir -p "$(dirname "$backup_dir/$tracked")"
        mv "$HOME/.config/$tracked" "$backup_dir/$tracked"
      fi
    done < <(git -C "$HOME/.config" ls-tree -r --name-only origin/master)
    git -C "$HOME/.config" checkout -q -B master --track origin/master
    rmdir --ignore-fail-on-non-empty "$backup_dir" 2>/dev/null || warn "Backed up pre-existing .config files to $backup_dir"
  else
    git -C "$HOME/.config" pull --ff-only -q || warn "$HOME/.config has local edits; skipped pull"
  fi

  chmod +x "$HOME/.config/scripts/"* 2>/dev/null || true
  ln -sfn "$HOME/.config/.p10k.zsh" "$HOME/.p10k.zsh"
  ln -sfn "$HOME/.config/.tmux.conf" "$HOME/.tmux.conf"
  ln -sfn "$HOME/.config/.vimrc" "$HOME/.vimrc"
  [[ -f "$HOME/.config/.zshrc" && ! -f "$HOME/.zshrc" ]] && cp "$HOME/.config/.zshrc" "$HOME/.zshrc"
  if [[ ! -f "$HOME/.zshenv" ]]; then
    cat > "$HOME/.zshenv" <<'EOF'
for _d in "$HOME/.local/share/pnpm/bin" "$HOME/.bun/bin" "$HOME/.cargo/bin" "$HOME/.local/bin"; do
  [ -d "$_d" ] && case ":$PATH:" in *":$_d:"*) ;; *) PATH="$_d:$PATH" ;; esac
done
export PATH
unset _d
EOF
  fi
  [[ -x "$HOME/.config/scripts/secrets-materialize" ]] && ln -sfn "$HOME/.config/scripts/secrets-materialize" "$LOCAL_BIN/secrets-materialize"
  if [[ -x "$HOME/.config/scripts/link-host-files.sh" && -d "$HOME/.config/hosts/$(uname -n)" ]]; then
    "$HOME/.config/scripts/link-host-files.sh"
  fi
  ok "$HOME/.config wired"
}

install_arch_packages() {
  [[ -f /etc/arch-release ]] || { warn "Non-Arch host detected; skipping pacman/yay OS package phase."; return 0; }
  log "Installing Arch Linux core & developer packages..."
  local -a cli_pkgs=(
    base-devel cmake git zsh tmux neovim ripgrep fd fzf jq duckdb shellcheck
    sccache github-cli tailscale docker docker-buildx docker-compose
    lazygit lazydocker go-task yazi btop htop unzip zip curl wget xclip xsel
    nodejs npm rbw perf strace zram-generator
  )
  sudo pacman -S --needed --noconfirm "${cli_pkgs[@]}"
  sudo systemctl enable --now tailscaled docker 2>/dev/null || true
  id -nG "$USER" | grep -qw docker || sudo usermod -aG docker "$USER"

  if ! command -v yay >/dev/null 2>&1; then
    log "Bootstrapping yay AUR helper..."
    local tmp_yay
    tmp_yay="$(mktemp -d)"
    git clone -q https://aur.archlinux.org/yay.git "$tmp_yay/yay"
    (cd "$tmp_yay/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp_yay"
  fi

  if [[ "$SKIP_GUI" -eq 0 ]]; then
    log "Installing Hyprland / Wayland desktop & GPU stack..."
    local -a gui_pkgs=(
      hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland xdg-desktop-portal
      waybar wofi fuzzel mako alacritty kitty thunar thunar-archive-plugin gvfs
      wl-clipboard grim slurp wf-recorder brightnessctl pipewire-pulse
      ttf-jetbrains-mono-nerd ttf-meslo-nerd ttf-liberation noto-fonts noto-fonts-emoji
      flatpak kdeconnect
    )
    sudo pacman -S --needed --noconfirm "${gui_pkgs[@]}"
    yay -S --needed --noconfirm quickshell brave-bin 2>/dev/null || warn "Optional AUR GUI package skipped"

    if lspci 2>/dev/null | grep -qi nvidia; then
      sudo pacman -S --needed --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver
    fi
    if lspci 2>/dev/null | grep -qi "vga.*intel\|display.*intel"; then
      sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel intel-media-driver
    fi
    if lspci 2>/dev/null | grep -qi "vga.*amd\|vga.*radeon"; then
      sudo pacman -S --needed --noconfirm vulkan-radeon lib32-vulkan-radeon
    fi
  fi

  if [[ "${SHELL:-}" != "$(command -v zsh)" ]] && command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" || warn "Run 'chsh -s $(command -v zsh)' manually to switch login shell"
  fi
  ok "Arch packages ready"
}

install_toolchains() {
  log "Ensuring Rust, Bun, UV, and pnpm toolchains..."
  if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
  fi
  ensure_path
  rustup toolchain install stable >/dev/null
  rustup component add clippy rustfmt rust-analyzer >/dev/null

  if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
  fi
  if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  if ! command -v pnpm >/dev/null 2>&1; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi
  ensure_path
  ok "Toolchains ready"
}

install_gh_release_bin() {
  local repo="$1" asset_regex="$2" bin_name="$3" extract_mode="${4:-tar}"
  if command -v "$bin_name" >/dev/null 2>&1; then
    ok "$bin_name already installed"
    return 0
  fi
  local tmp_dl url
  tmp_dl="$(mktemp -d)"
  url="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | jq -r --arg re "$asset_regex" '.assets[] | select(.name | test($re)) | .browser_download_url' \
    | head -n 1)"
  if [[ -z "$url" || "$url" == "null" ]]; then
    rm -rf "$tmp_dl"
    warn "Could not resolve latest release asset for $repo ($bin_name)"
    return 1
  fi
  curl -fsSL "$url" -o "$tmp_dl/archive"
  if [[ "$extract_mode" == "raw" ]]; then
    install -m 0755 "$tmp_dl/archive" "$LOCAL_BIN/$bin_name"
  else
    tar -xf "$tmp_dl/archive" -C "$tmp_dl"
    local found
    found="$(find "$tmp_dl" -type f -name "$bin_name" | head -n 1)"
    [[ -n "$found" ]] && install -m 0755 "$found" "$LOCAL_BIN/$bin_name"
  fi
  rm -rf "$tmp_dl"
  ok "Installed $bin_name -> $LOCAL_BIN/$bin_name"
}

install_cli_arsenal() {
  log "Installing Cargo & Security CLI arsenal..."
  ensure_path
  if ! command -v cargo-binstall >/dev/null 2>&1; then
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
  fi

  local -a crates=(ast-grep cargo-audit cargo-deny cargo-nextest cargo-mutants fallow-cli hyperfine sd xh)
  local crate
  for crate in "${crates[@]}"; do
    local check_bin="${crate%-cli}"
    command -v "$check_bin" >/dev/null 2>&1 || cargo binstall -y --no-symlinks "$crate" || cargo install --locked "$crate"
  done

  uv tool list 2>/dev/null | grep -q '^semgrep ' || uv tool install semgrep
  uv tool list 2>/dev/null | grep -q '^zizmor '  || uv tool install zizmor

  local arch
  arch="$(uname -m)"
  if [[ "$arch" == "x86_64" ]]; then
    install_gh_release_bin "gitleaks/gitleaks" "gitleaks_.*_linux_x64\\.tar\\.gz$" "gitleaks" "tar"
    install_gh_release_bin "google/osv-scanner" "osv-scanner_linux_amd64$" "osv-scanner" "raw"
    install_gh_release_bin "rhysd/actionlint" "actionlint_.*_linux_amd64\\.tar\\.gz$" "actionlint" "tar"
    install_gh_release_bin "aquasecurity/trivy" "trivy_.*_Linux-64bit\\.tar\\.gz$" "trivy" "tar"
    install_gh_release_bin "hadolint/hadolint" "^hadolint-Linux-x86_64$" "hadolint" "raw"
    install_gh_release_bin "mikefarah/yq" "^yq_linux_amd64$" "yq" "raw"
  fi
  ok "Security & Cargo CLI arsenal ready"
}

build_rust_dir() {
  local manifest_dir="$1" slug="$2"
  [[ -f "$manifest_dir/Cargo.toml" ]] || return 0
  mkdir -p "$CARGO_TARGET_BASE/$slug"
  CARGO_TARGET_DIR="$CARGO_TARGET_BASE/$slug" cargo build --release --manifest-path "$manifest_dir/Cargo.toml"
}

install_claude_and_iron_stack() {
  log "Setting up Claude Code, Personal Harness, and Iron Suite..."
  ensure_path
  if ! command -v claude >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  ensure_path

  if clone_or_pull_repo "entropy-hunter" "$PROJECTS_DIR/entropy-hunter" "public"; then
    if ! command -v entropy >/dev/null 2>&1; then
      CARGO_TARGET_DIR="$CARGO_TARGET_BASE/entropy-hunter" cargo install --path "$PROJECTS_DIR/entropy-hunter" --locked 2>/dev/null || true
    fi
  fi
  clone_or_pull_repo "lazyfetch" "$PROJECTS_DIR/lazyfetch" "public" || true
  clone_or_pull_repo "term-toolkit" "$PROJECTS_DIR/term-toolkit" "public" || true

  if clone_or_pull_repo "claude-config" "$HOME/.claude" "private"; then
    chmod 700 "$HOME/.claude"
    build_rust_dir "$HOME/.claude/hooks/guardrail" "claude-guardrail"
    [[ -f "$CARGO_TARGET_BASE/claude-guardrail/release/guardrail" ]] && \
      install -m 0755 "$CARGO_TARGET_BASE/claude-guardrail/release/guardrail" "$HOME/.claude/hooks/guardrail/target-bin" 2>/dev/null || true
    build_rust_dir "$HOME/.claude/coordinator" "claude-coordinator"
    build_rust_dir "$HOME/.claude/hooks/harness-tui" "claude-harness-tui"
    [[ -x "$HOME/.claude/hooks/sync-codex-skills.sh" ]] && bash "$HOME/.claude/hooks/sync-codex-skills.sh" || true
  fi

  if clone_or_pull_repo "notes" "$PROJECTS_DIR/notes" "private"; then
    ln -sfn "$PROJECTS_DIR/notes" "$HOME/notes"
  fi

  mkdir -p "$HOME/.local/share/iron" "$HOME/.config/iron"
  chmod 700 "$HOME/.local/share/iron" "$HOME/.config/iron"

  if clone_or_pull_repo "iron-suite" "$PROJECTS_DIR/iron-suite" "public"; then
    build_rust_dir "$PROJECTS_DIR/iron-suite" "iron-suite"
    install -m 0755 "$CARGO_TARGET_BASE/iron-suite/release/iron" "$LOCAL_BIN/iron"
    install -m 0755 "$PROJECTS_DIR/iron-suite/integration/iron-memory-backup.sh" "$LOCAL_BIN/iron-memory-backup"
    install -m 0600 "$PROJECTS_DIR/iron-suite/integration/gitleaks-export.toml" "$HOME/.config/iron/gitleaks-export.toml"
  fi

  clone_or_pull_repo "iron-memories" "$HOME/.local/share/iron/git-vault" "private" || true

  if [[ -x "$LOCAL_BIN/iron" ]]; then
    local -a import_args=(--db "$HOME/.local/share/iron/memory.db" memory import)
    [[ -d "$HOME/.claude" ]] && import_args+=(--claude-root "$HOME/.claude")
    [[ -f "$HOME/.cavemem/data.db" ]] && import_args+=(--cavemem-db "$HOME/.cavemem/data.db")
    if [[ "${#import_args[@]}" -gt 4 ]]; then
      "$LOCAL_BIN/iron" "${import_args[@]}" >/dev/null || warn "Initial iron memory import skipped"
    fi
    if command -v claude >/dev/null 2>&1; then
      claude mcp get iron-memory >/dev/null 2>&1 || \
        claude mcp add-json iron-memory "{\"type\":\"stdio\",\"command\":\"$LOCAL_BIN/iron\",\"args\":[\"mcp\"]}" --scope user || true
    fi
  fi
  ok "Claude & Iron Stack configured"
}

setup_systemd_user_units() {
  command -v systemctl >/dev/null 2>&1 || return 0
  log "Materializing systemd --user services & timers..."
  local unit_dir="$HOME/.config/systemd/user"
  mkdir -p "$unit_dir"

  cat > "$unit_dir/iron-memory-refresh.service" <<'EOF'
[Unit]
Description=Refresh imported Iron memory sources

[Service]
Type=oneshot
UMask=0077
Nice=10
ExecStart=/bin/sh -c 'args="--db %h/.local/share/iron/memory.db memory import"; [ -d "%h/.claude" ] && args="$args --claude-root %h/.claude"; [ -f "%h/.cavemem/data.db" ] && args="$args --cavemem-db %h/.cavemem/data.db"; exec "%h/.local/bin/iron" $args'
EOF

  cat > "$unit_dir/iron-memory-refresh.timer" <<'EOF'
[Unit]
Description=Refresh imported Iron memory every five minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=iron-memory-refresh.service

[Install]
WantedBy=timers.target
EOF

  cat > "$unit_dir/iron-memory-backup.service" <<'EOF'
[Unit]
Description=Verified rolling SQLite backup of authoritative Iron Memory store

[Service]
Type=oneshot
UMask=0077
Nice=10
IOSchedulingClass=idle
ExecStart=%h/.local/bin/iron-memory-backup
EOF

  cat > "$unit_dir/iron-memory-backup.timer" <<'EOF'
[Unit]
Description=Nightly rolling backup of authoritative Iron Memory store

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
RandomizedDelaySec=5m
Unit=iron-memory-backup.service

[Install]
WantedBy=timers.target
EOF

  cat > "$unit_dir/secrets-materialize.service" <<'EOF'
[Unit]
Description=Rebuild secret files from rbw into RAM (/run/user/UID/secrets)

[Service]
Type=oneshot
Environment=PATH=%h/.cargo/bin:%h/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=%h/.local/bin/secrets-materialize --if-missing
SuccessExitStatus=75
EOF

  cat > "$unit_dir/secrets-materialize.timer" <<'EOF'
[Unit]
Description=Rebuild missing secret files from rbw

[Timer]
OnStartupSec=20s
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF

  cat > "$unit_dir/clean-tmp-cargo.service" <<'EOF'
[Unit]
Description=Purge stale cargo target dirs from /tmp ramdisk

[Service]
Type=oneshot
ExecStart=%h/.config/scripts/clean-tmp-cargo -d 1
EOF

  cat > "$unit_dir/clean-tmp-cargo.timer" <<'EOF'
[Unit]
Description=Daily /tmp cargo target cleanup

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

  cat > "$unit_dir/clean-user-caches.service" <<'EOF'
[Unit]
Description=Prune dev-tool caches and stale trash

[Service]
Type=oneshot
ExecStart=%h/.config/scripts/clean-user-caches
EOF

  cat > "$unit_dir/clean-user-caches.timer" <<'EOF'
[Unit]
Description=Weekly user cache cleanup

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

  if [[ -f "$HOME/.config/theme/aurora/systemd/aurora-sync.path" ]]; then
    ln -sfn "$HOME/.config/theme/aurora/systemd/aurora-sync.path" "$unit_dir/aurora-sync.path"
    ln -sfn "$HOME/.config/theme/aurora/systemd/aurora-sync.service" "$unit_dir/aurora-sync.service"
  fi
  if [[ -f "$HOME/.claude/hooks/relearn/systemd/claude-relearn.timer" ]]; then
    ln -sfn "$HOME/.claude/hooks/relearn/systemd/claude-relearn.service" "$unit_dir/claude-relearn.service"
    ln -sfn "$HOME/.claude/hooks/relearn/systemd/claude-relearn.timer" "$unit_dir/claude-relearn.timer"
  fi

  systemctl --user daemon-reload || true
  local timer
  for timer in \
    iron-memory-refresh.timer \
    iron-memory-backup.timer \
    secrets-materialize.timer \
    clean-tmp-cargo.timer \
    clean-user-caches.timer; do
    [[ -f "$unit_dir/$timer" ]] && systemctl --user enable --now "$timer" 2>/dev/null || true
  done
  [[ -L "$unit_dir/aurora-sync.path" ]] && systemctl --user enable --now aurora-sync.path 2>/dev/null || true
  [[ -L "$unit_dir/claude-relearn.timer" ]] && systemctl --user enable --now claude-relearn.timer 2>/dev/null || true

  if [[ -x "$LOCAL_BIN/secrets-materialize" ]]; then
    "$LOCAL_BIN/secrets-materialize" --if-missing || true
  fi
  ok "Systemd user timers enabled"
}

main() {
  if [[ "$CHECK_ONLY" -eq 1 ]]; then
    check_status
    exit 0
  fi

  if [[ "$ASSUME_YES" -eq 0 ]]; then
    printf 'Replicate desktop setup (%s mode) on host %s? [y/N] ' "$MODE" "$(uname -n)"
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
  fi

  bootstrap_dotconfig
  if [[ "$MODE" == "full" ]]; then
    install_arch_packages
  fi
  install_toolchains
  install_cli_arsenal
  install_claude_and_iron_stack
  setup_systemd_user_units
  echo ""
  check_status
}

main
