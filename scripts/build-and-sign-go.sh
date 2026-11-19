#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# build-and-sign-go.sh - Go build/package/sign helper for crash-game-rng
# =============================================================================
# Produces:
# - {prefix}-src.zip
# - {prefix}-dist.zip
# - {prefix}.md5 / {prefix}.sha1
# - {prefix}-dist.md5 / {prefix}-dist.sha1
# - LOG.txt / SCR.txt / TXB.txt / TXS.txt
# =============================================================================

SCRIPT_NAME="$(basename "$0")"
CRITICAL_FILES_NAME="critical_files.txt"

SOURCE_DIR=""
PREFIX=""
GIT_BRANCH="main"
BINARY_NAME="crash-game-rng"

BASE_WORK_DIR=""
WORK_DIR=""
LOG_FILE=""
BUILD_STAGE_DIR=""
CLEANED_DIR=""

log_message() {
  local message="$1"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  if [ -n "${LOG_FILE:-}" ]; then
    echo "[$ts] $message" | tee -a "$LOG_FILE"
  else
    echo "[$ts] $message"
  fi
}

log_command() {
  local cmd="$1"
  log_message "EXECUTING: $cmd"
}

log_error() {
  local message="$1"
  log_message "ERROR: $message"
}

show_help() {
  cat <<EOF
build-and-sign-go - Build and package Go project with integrity files

USAGE:
  $SCRIPT_NAME [source-folder] [prefix] [git-branch] [binary-name]
  $SCRIPT_NAME --help | -h

ARGUMENTS:
  source-folder  Optional source folder (default: current directory)
  prefix         Optional output prefix (default: crash-game-rng)
  git-branch     Optional git branch to build from (default: main)
  binary-name    Optional output binary name (default: crash-game-rng)

EXAMPLES:
  $SCRIPT_NAME
  $SCRIPT_NAME . crash-game-rng main crash-game-rng
EOF
}

resolve_source_dir() {
  local source="$1"
  if [[ "$source" != /* ]]; then
    SOURCE_DIR="$(cd "$source" && pwd)"
  else
    SOURCE_DIR="$source"
  fi
}

validate_and_setup() {
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
    exit 0
  fi

  local source_arg="${1:-.}"
  PREFIX="${2:-crash-game-rng}"
  GIT_BRANCH="${3:-main}"
  BINARY_NAME="${4:-crash-game-rng}"

  resolve_source_dir "$source_arg"

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory not found: $SOURCE_DIR" >&2
    exit 1
  fi

  BASE_WORK_DIR="$(pwd)"
  WORK_DIR="${BASE_WORK_DIR}/output-${PREFIX}"
  LOG_FILE="${WORK_DIR}/LOG.txt"
  BUILD_STAGE_DIR="${WORK_DIR}/build"
  CLEANED_DIR="${BASE_WORK_DIR}/${PREFIX}-clean"

  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR" "$BUILD_STAGE_DIR"
  : > "$LOG_FILE"

  log_message "Build script started"
  log_message "Source directory: $SOURCE_DIR"
  log_message "Output directory: $WORK_DIR"
  log_message "Prefix: $PREFIX"
  log_message "Git branch: $GIT_BRANCH"
  log_message "Binary name: $BINARY_NAME"
}

validate_git_repository() {
  log_message "Validating git repository..."

  if ! command -v git >/dev/null 2>&1; then
    log_error "git command not available in PATH"
    exit 1
  fi

  if ! git -C "$SOURCE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    log_error "No git repository found at or above source directory: $SOURCE_DIR"
    exit 1
  fi

  local current_branch
  current_branch="$(cd "$SOURCE_DIR" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
  log_message "Current branch: $current_branch"
  log_message "Commit: $(cd "$SOURCE_DIR" && git rev-parse HEAD 2>/dev/null || echo "unknown")"
}

build_go_binary() {
  log_message "Building Go binary..."

  if ! command -v go >/dev/null 2>&1; then
    log_error "go command not available in PATH"
    exit 1
  fi

  local git_commit_hash=""
  git_commit_hash="$(cd "$SOURCE_DIR" && git rev-parse HEAD 2>/dev/null || true)"

  log_command "cd \"$SOURCE_DIR\" && go version"
  (cd "$SOURCE_DIR" && go version 2>&1 | tee -a "$LOG_FILE")

  log_command "cd \"$SOURCE_DIR\" && go mod tidy"
  (cd "$SOURCE_DIR" && go mod tidy 2>&1 | tee -a "$LOG_FILE")

  log_command "cd \"$SOURCE_DIR\" && CGO_ENABLED=0 go build -trimpath -buildvcs=true -ldflags \"-s -w\" -o \"$BUILD_STAGE_DIR/$BINARY_NAME\" ."
  (
    cd "$SOURCE_DIR" && \
      CGO_ENABLED=0 \
      GOFLAGS="-buildvcs=true" \
      GIT_COMMIT_HASH="$git_commit_hash" \
      go build -trimpath -ldflags "-s -w" -o "$BUILD_STAGE_DIR/$BINARY_NAME" . 2>&1 | tee -a "$LOG_FILE"
  )

  if [ ! -f "$BUILD_STAGE_DIR/$BINARY_NAME" ]; then
    log_error "Build output not found: $BUILD_STAGE_DIR/$BINARY_NAME"
    exit 1
  fi
}

create_dist_package() {
  log_message "Creating dist package..."
  log_command "cd \"$BUILD_STAGE_DIR\" && zip -r \"$WORK_DIR/${PREFIX}-dist.zip\" ."
  (cd "$BUILD_STAGE_DIR" && zip -r "$WORK_DIR/${PREFIX}-dist.zip" . 2>&1 | tee -a "$LOG_FILE")

  log_command "cd \"$BUILD_STAGE_DIR\" && find . -type f -exec md5sum {} \\;"
  (cd "$BUILD_STAGE_DIR" && find . -type f -exec md5sum {} \; > "$WORK_DIR/${PREFIX}-dist.md5")

  log_command "cd \"$BUILD_STAGE_DIR\" && find . -type f -exec sha1sum {} \\;"
  (cd "$BUILD_STAGE_DIR" && find . -type f -exec sha1sum {} \; > "$WORK_DIR/${PREFIX}-dist.sha1")
}

create_clean_source_copy() {
  log_message "Creating clean source snapshot..."

  rm -rf "$CLEANED_DIR"
  mkdir -p "$CLEANED_DIR"

  log_command "Copy source excluding .git, outputs, zips, checksum artifacts, and this script"
  find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 \
    ! -name '.git' \
    ! -name '.github' \
    ! -name 'output-*' \
    ! -name '*.zip' \
    ! -name '*.md5' \
    ! -name '*.sha1' \
    ! -name "$SCRIPT_NAME" \
    ! -name "${PREFIX}-clean" \
    -exec cp -r {} "$CLEANED_DIR/" \;
}

create_source_package_and_checksums() {
  log_message "Creating source package and checksum files..."

  log_command "cd \"$CLEANED_DIR\" && find . -type f -exec md5sum {} \\;"
  (cd "$CLEANED_DIR" && find . -type f -exec md5sum {} \; > "$WORK_DIR/${PREFIX}.md5")

  log_command "cd \"$CLEANED_DIR\" && find . -type f -exec sha1sum {} \\;"
  (cd "$CLEANED_DIR" && find . -type f -exec sha1sum {} \; > "$WORK_DIR/${PREFIX}.sha1")

  log_command "cd \"$CLEANED_DIR\" && zip -r \"$WORK_DIR/${PREFIX}-src.zip\" ."
  (cd "$CLEANED_DIR" && zip -r "$WORK_DIR/${PREFIX}-src.zip" . 2>&1 | tee -a "$LOG_FILE")
}

generate_txb_txt() {
  local txb_file="$WORK_DIR/TXB.txt"
  local critical_file="$SOURCE_DIR/$CRITICAL_FILES_NAME"
  : > "$txb_file"

  if [ ! -f "$critical_file" ]; then
    log_message "No $CRITICAL_FILES_NAME found. TXB.txt left empty."
    return
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    local path
    path="$(echo "$line" | xargs)"

    local local_path="$SOURCE_DIR/$path"
    if [[ "$path" == /* ]]; then
      local_path="$path"
    fi

    if [ -f "$local_path" ]; then
      local sha1
      sha1="$(sha1sum "$local_path" | cut -d' ' -f1)"
      printf "%s  %s\n" "$sha1" "$path" >> "$txb_file"
    else
      log_message "WARNING: Critical file not found locally: $local_path"
    fi
  done < "$critical_file"
}

generate_txs_txt() {
  local txs_file="$WORK_DIR/TXS.txt"
  : > "$txs_file"

  (cd "$CLEANED_DIR" && find . -type f | sed 's|^\./||' | sort | while IFS= read -r rel; do
    local sha1
    sha1="$(sha1sum "$CLEANED_DIR/$rel" | cut -d' ' -f1)"
    printf "%s  %s\n" "$sha1" "$rel" >> "$txs_file"
  done)
}

generate_scr_txt() {
  local scr_file="$WORK_DIR/SCR.txt"

  cat > "$scr_file" <<EOF
VERIFICATION PROCEDURE FOR CRITICAL FILES
==========================================

Project: ${PREFIX}
Build Date: $(date '+%Y-%m-%d %H:%M:%S')
Source Directory: ${SOURCE_DIR}
Binary Name: ${BINARY_NAME}

Artifacts generated by this script:
1. ${PREFIX}-src.zip      (source package)
2. ${PREFIX}-dist.zip     (compiled Go binary package)
3. TXS.txt                (SHA-1 for all source package files)
4. TXB.txt                (SHA-1 for critical files listed in ${CRITICAL_FILES_NAME})
5. LOG.txt                (audit log of commands and timestamps)

Manual verification steps:
1. Unzip ${PREFIX}-src.zip and ${PREFIX}-dist.zip in an isolated machine.
2. Run:
   - sha1sum <critical-file>      and compare against TXB.txt
   - sha1sum <source-file>        and compare against TXS.txt
3. Rebuild from source using the command in LOG.txt and verify produced binary hash.
4. Record verifier identity, timestamp, and any discrepancies.
EOF
}

generate_log_summary() {
  log_message "Writing final build summary..."
  log_message "Source package: $WORK_DIR/${PREFIX}-src.zip"
  log_message "Dist package:   $WORK_DIR/${PREFIX}-dist.zip"
  log_message "Checksums:      ${PREFIX}.md5, ${PREFIX}.sha1, ${PREFIX}-dist.md5, ${PREFIX}-dist.sha1"
  log_message "Deliverables:   LOG.txt, SCR.txt, TXB.txt, TXS.txt"

  if [ -f "$WORK_DIR/${PREFIX}-src.zip" ]; then
    log_message "SHA1(${PREFIX}-src.zip): $(sha1sum "$WORK_DIR/${PREFIX}-src.zip" | cut -d' ' -f1)"
  fi
  if [ -f "$WORK_DIR/${PREFIX}-dist.zip" ]; then
    log_message "SHA1(${PREFIX}-dist.zip): $(sha1sum "$WORK_DIR/${PREFIX}-dist.zip" | cut -d' ' -f1)"
  fi
}

cleanup() {
  log_message "Cleaning temporary directories..."
  rm -rf "$CLEANED_DIR"
}

main() {
  validate_and_setup "$@"
  validate_git_repository
  build_go_binary
  create_dist_package
  create_clean_source_copy
  create_source_package_and_checksums
  generate_txb_txt
  generate_txs_txt
  generate_scr_txt
  generate_log_summary
  cleanup

  log_message "Build and signing flow completed successfully."
  echo "All files generated in: $WORK_DIR"
}

main "$@"
