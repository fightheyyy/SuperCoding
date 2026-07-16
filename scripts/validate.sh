#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
VALIDATOR="$CODEX_ROOT/skills/.system/skill-creator/scripts/quick_validate.py"
PYTHON_BIN="${PYTHON_BIN:-python3}"
SKILLS="supergoal superdev superreview"

required_files="
skills/supergoal/SKILL.md
skills/supergoal/agents/openai.yaml
skills/supergoal/references/goal-contract-template.md
skills/superdev/SKILL.md
skills/superdev/agents/openai.yaml
skills/superreview/SKILL.md
skills/superreview/agents/openai.yaml
skills/superreview/agents/superreview-repair.toml
skills/superreview/assets/superreview-icon.png
skills/superreview/assets/superreview-icon.svg
docs/hero.svg
docs/social-preview.png
"

for relative_path in $required_files; do
  if [ ! -f "$ROOT_DIR/$relative_path" ]; then
    printf 'Missing required file: %s\n' "$relative_path" >&2
    exit 1
  fi
done

for skill in $SKILLS; do
  expected="name: $skill"
  if ! grep -q "$expected" "$ROOT_DIR/skills/$skill/SKILL.md"; then
    printf 'Frontmatter name mismatch: %s\n' "$skill" >&2
    exit 1
  fi
done

repair_agent="$ROOT_DIR/skills/superreview/agents/superreview-repair.toml"
grep -q '^name = "superreview-repair"$' "$repair_agent"
grep -q '^model = "gpt-5.6-sol"$' "$repair_agent"
grep -q '^model_reasoning_effort = "xhigh"$' "$repair_agent"

xmllint --noout "$ROOT_DIR/docs/hero.svg" "$ROOT_DIR/skills/superreview/assets/superreview-icon.svg"

if [ -f "$VALIDATOR" ] && "$PYTHON_BIN" -c 'import yaml' >/dev/null 2>&1; then
  for skill in $SKILLS; do
    "$PYTHON_BIN" "$VALIDATOR" "$ROOT_DIR/skills/$skill"
  done
else
  printf 'Official quick_validate.py skipped: validator or PyYAML unavailable.\n'
fi

printf 'SuperCoding structural validation passed.\n'
