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

update_managed_file() {
  local rel="$1"
  local src="$ROOT_DIR/templates/managed/$rel"
  local dest="$TARGET_DIR/$rel"
  local backup="$BACKUP_DIR/$rel"

  mkdir -p "$(dirname "$dest")"

  if [[ ! -f "$dest" ]]; then
    cp "$src" "$dest"
    echo "installed missing managed file: $rel"
    UPDATED=1
    return
  fi

  if cmp -s "$src" "$dest"; then
    echo "up to date: $rel"
    return
  fi

  mkdir -p "$(dirname "$backup")"
  cp "$dest" "$backup"
  cp "$src" "$dest"
  echo "updated managed file: $rel (backup: $backup)"
  UPDATED=1
}

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" ]] && continue
  update_managed_file "$rel"
done < "$MANAGED_LIST"

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
