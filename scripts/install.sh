#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$PWD}"
FORCE="${2:-}"
STATE_DIR="$TARGET_DIR/.openclaw-bootstrap"
MANAGED_LIST="$ROOT_DIR/managed-files.txt"

mkdir -p "$TARGET_DIR" "$STATE_DIR" "$TARGET_DIR/memory"

local_override_path_for() {
  local rel="$1"
  printf '%s/%s.local.md' "$TARGET_DIR" "${rel%.md}"
}

render_managed_file() {
  local rel="$1"
  local src="$ROOT_DIR/templates/managed/$rel"
  local dest="$TARGET_DIR/$rel"
  local local_override
  local_override="$(local_override_path_for "$rel")"

  if [[ -f "$dest" && "$FORCE" != "--force" ]]; then
    echo "skip managed file already exists: $rel"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cat "$src" > "$dest"

  if [[ -f "$local_override" ]]; then
    printf '\n\n## Local workstation additions\n\n' >> "$dest"
    cat "$local_override" >> "$dest"
  fi

  echo "rendered managed file: $rel"
}

copy_local_example_if_missing() {
  local example_name="$1"
  local target_name="$2"
  local src="$ROOT_DIR/templates/local/$example_name"
  local dest="$TARGET_DIR/$target_name"

  if [[ -f "$dest" ]]; then
    echo "keep existing local file: $target_name"
    return
  fi

  cp "$src" "$dest"
  echo "created local file from template: $target_name"
}

copy_local_example_if_missing "AGENTS.local.md.example" "AGENTS.local.md"
copy_local_example_if_missing "SOUL.local.md.example" "SOUL.local.md"
copy_local_example_if_missing "HEARTBEAT.local.md.example" "HEARTBEAT.local.md"
copy_local_example_if_missing "IDENTITY.md.example" "IDENTITY.md"
copy_local_example_if_missing "USER.md.example" "USER.md"
copy_local_example_if_missing "TOOLS.md.example" "TOOLS.md"

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" ]] && continue
  render_managed_file "$rel"
done < "$MANAGED_LIST"

cp "$MANAGED_LIST" "$STATE_DIR/managed-files.txt"

echo "installedAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$STATE_DIR/install-state.txt"
if git -C "$ROOT_DIR" rev-parse HEAD >/dev/null 2>&1; then
  echo "sourceCommit=$(git -C "$ROOT_DIR" rev-parse HEAD)" >> "$STATE_DIR/install-state.txt"
fi

echo "bootstrap install complete: $TARGET_DIR"
