#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
FORCE=0

usage() {
  printf 'Usage: %s [--force] [--codex-home PATH]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --codex-home)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      CODEX_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SKILLS_DIR="$CODEX_ROOT/skills"
AGENTS_DIR="$CODEX_ROOT/agents"
STAMP="$(date +%Y%m%d-%H%M%S)"
SKILLS="supergoal superdev superreview"
REPAIR_AGENT="superreview-repair.toml"

if [ "$FORCE" -ne 1 ]; then
  for skill in $SKILLS; do
    if [ -e "$SKILLS_DIR/$skill" ]; then
      printf 'Destination already exists: %s\n' "$SKILLS_DIR/$skill" >&2
      printf 'Re-run with --force to create timestamped backups first.\n' >&2
      exit 1
    fi
  done

  if [ -e "$AGENTS_DIR/$REPAIR_AGENT" ]; then
    printf 'Destination already exists: %s\n' "$AGENTS_DIR/$REPAIR_AGENT" >&2
    printf 'Re-run with --force to create a timestamped backup first.\n' >&2
    exit 1
  fi
fi

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

backup_if_needed() {
  local target="$1"
  if [ -e "$target" ]; then
    local backup="${target}.backup-${STAMP}"
    local suffix=1
    while [ -e "$backup" ]; do
      backup="${target}.backup-${STAMP}-${suffix}"
      suffix=$((suffix + 1))
    done
    mv "$target" "$backup"
    printf 'Backed up %s -> %s\n' "$target" "$backup"
  fi
}

for skill in $SKILLS; do
  source_dir="$ROOT_DIR/skills/$skill"
  target_dir="$SKILLS_DIR/$skill"
  backup_if_needed "$target_dir"
  cp -R "$source_dir" "$target_dir"
  printf 'Installed %s -> %s\n' "$skill" "$target_dir"
done

repair_source="$ROOT_DIR/skills/superreview/agents/$REPAIR_AGENT"
repair_target="$AGENTS_DIR/$REPAIR_AGENT"
backup_if_needed "$repair_target"
cp "$repair_source" "$repair_target"
printf 'Registered repair agent -> %s\n' "$repair_target"

printf '\nSuperCoding installed. Restart Codex to refresh skill discovery.\n'
