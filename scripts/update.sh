#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$PWD}"
STATE_DIR="$TARGET_DIR/.openclaw-bootstrap"
MANAGED_LIST="$ROOT_DIR/managed-files.txt"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"
UPDATED=0

mkdir -p "$TARGET_DIR" "$STATE_DIR" "$BACKUP_DIR"

local_override_path_for() {
  local rel="$1"
  printf '%s/%s.local.md' "$TARGET_DIR" "${rel%.md}"
}

render_expected_to() {
  local rel="$1"
  local output_file="$2"
  local src="$ROOT_DIR/templates/managed/$rel"
  local local_override
  local_override="$(local_override_path_for "$rel")"

  cat "$src" > "$output_file"

  if [[ -f "$local_override" ]]; then
    printf '\n\n## Local workstation additions\n\n' >> "$output_file"
    cat "$local_override" >> "$output_file"
  fi
}

update_managed_file() {
  local rel="$1"
  local dest="$TARGET_DIR/$rel"
  local backup="$BACKUP_DIR/$rel"
  local expected
  expected="$(mktemp)"
  render_expected_to "$rel" "$expected"

  mkdir -p "$(dirname "$dest")"

  if [[ ! -f "$dest" ]]; then
    cp "$expected" "$dest"
    echo "installed missing managed file: $rel"
    UPDATED=1
    rm -f "$expected"
    return
  fi

  if cmp -s "$expected" "$dest"; then
    echo "up to date: $rel"
    rm -f "$expected"
    return
  fi

  mkdir -p "$(dirname "$backup")"
  cp "$dest" "$backup"
  cp "$expected" "$dest"
  rm -f "$expected"
  echo "updated managed file: $rel (backup: $backup)"
  UPDATED=1
}

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" ]] && continue
  update_managed_file "$rel"
done < "$MANAGED_LIST"

mkdir -p "$TARGET_DIR/company"
if rsync -ani "$ROOT_DIR/company/" "$TARGET_DIR/company/" | grep -q .; then
  if [[ -d "$TARGET_DIR/company" ]]; then
    mkdir -p "$BACKUP_DIR"
    rsync -a "$TARGET_DIR/company/" "$BACKUP_DIR/company/"
  fi
  rsync -a "$ROOT_DIR/company/" "$TARGET_DIR/company/"
  echo "updated managed directory: company/"
  UPDATED=1
else
  echo "up to date: company/"
fi

cp "$MANAGED_LIST" "$STATE_DIR/managed-files.txt"

echo "updatedAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$STATE_DIR/update-state.txt"
if git -C "$ROOT_DIR" rev-parse HEAD >/dev/null 2>&1; then
  echo "sourceCommit=$(git -C "$ROOT_DIR" rev-parse HEAD)" >> "$STATE_DIR/update-state.txt"
fi

if [[ "$UPDATED" -eq 0 ]]; then
  rmdir "$BACKUP_DIR" 2>/dev/null || true
  echo "no managed file changes were needed"
else
  echo "bootstrap update complete: $TARGET_DIR"
fi
