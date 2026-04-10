#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CAVEMAN_REPO="https://github.com/JuliusBrussee/caveman.git"
CAVEMAN_DIR="vendor/caveman"
SKILLS_DIR="skills"

CAVEMAN_SKILLS=(
  caveman
  caveman-commit
  caveman-review
)

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[ok]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[1;33m[warn]\033[0m  %s\n" "$*"; }
fail()  { printf "\033[1;31m[fail]\033[0m  %s\n" "$*" >&2; exit 1; }

step_1_deps() {
  info "Installing npm dependencies via bun..."
  if ! command -v bun &>/dev/null; then
    fail "bun is not installed. Install it from https://bun.sh or switch to npm."
  fi
  bun install
  ok "Dependencies installed."
}

step_2_caveman() {
  info "Setting up caveman submodule..."

  is_submodule=false
  if [ -f "$CAVEMAN_DIR/.git" ] || git config --file .gitmodules "submodule.$CAVEMAN_DIR.url" &>/dev/null; then
    is_submodule=true
  fi

  if $is_submodule; then
    info "Submodule exists, updating..."
    git submodule update --init "$CAVEMAN_DIR"
    ok "Caveman submodule updated."
  elif [ -d "$CAVEMAN_DIR" ]; then
    warn "$CAVEMAN_DIR exists but is not a git submodule. Skipping."
    warn "Remove it manually and re-run to use a submodule instead."
  else
    git submodule add "$CAVEMAN_REPO" "$CAVEMAN_DIR"
    ok "Caveman submodule added."
  fi
}

step_3_symlinks() {
  info "Linking caveman skills..."
  mkdir -p "$SKILLS_DIR"

  for skill in "${CAVEMAN_SKILLS[@]}"; do
    target="$SKILLS_DIR/$skill"
    source="../$CAVEMAN_DIR/skills/$skill"

    if [ -L "$target" ]; then
      link_dest="$(readlink "$target")"
      if [ "$link_dest" = "$source" ]; then
        ok "$skill (already linked)"
      else
        warn "$skill points to unexpected target: $link_dest (expected $source). Skipping."
      fi
    elif [ -e "$target" ]; then
      warn "$target exists and is not a symlink. Skipping to avoid clobbering."
    elif [ -d "$CAVEMAN_DIR/skills/$skill" ]; then
      ln -s "$source" "$target"
      ok "$skill linked."
    else
      warn "Source $CAVEMAN_DIR/skills/$skill not found. Skipping."
    fi
  done
}

step_4_verify() {
  info "Verification:"
  echo ""

  printf "  Plugins (opencode.json):\n"
  if [ -f opencode.json ]; then
    python3 -c "
import json, sys
with open('opencode.json') as f:
    data = json.load(f)
for p in data.get('plugin', []):
    print(f'    - {p}')
" 2>/dev/null || python -c "
import json
with open('opencode.json') as f:
    data = json.load(f)
for p in data.get('plugin', []):
    print('    - {}'.format(p))
" 2>/dev/null || echo "    (could not parse opencode.json)"
  fi
  echo ""

  printf "  Skills:\n"
  for skill in "${CAVEMAN_SKILLS[@]}"; do
    target="$SKILLS_DIR/$skill"
    if [ -L "$target" ] && [ -f "$target/SKILL.md" ]; then
      ok "    $skill"
    else
      warn "    $skill (missing or broken)"
    fi
  done
  echo ""

  info "Note: @tarquinen/opencode-dcp and opencode-handoff auto-fetch from npm on opencode restart."
  info "Restart opencode to pick up all changes."
}

main() {
  info "=== opencode config setup ==="
  echo ""
  step_1_deps
  echo ""
  step_2_caveman
  echo ""
  step_3_symlinks
  echo ""
  step_4_verify
  echo ""
  ok "Done."
}

main "$@"
