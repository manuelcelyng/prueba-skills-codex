#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(pwd)}"
AI_KIT_DIR="$REPO_ROOT/.ai-kit"
CORE_SKILLS_DIR="$AI_KIT_DIR/skills"
LOCAL_SKILLS_DIR="$REPO_ROOT/skills"
OUT_DIR="$REPO_ROOT/.ai/skills"

err() { echo "build-skills: $*" 1>&2; }

LOCK_FILE="$REPO_ROOT/ai-kit.lock"
if [ -f "$LOCK_FILE" ]; then
  # Optional: allow repos to force a stack when auto-detection is not possible yet.
  # shellcheck disable=SC1090
  source "$LOCK_FILE"
fi

if [ ! -d "$AI_KIT_DIR" ]; then
  err "missing .ai-kit/. Run ./scripts/ai/bootstrap.sh first."
  exit 1
fi

mkdir -p "$REPO_ROOT/.ai"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

is_java=false
is_python=false

if [ -f "$REPO_ROOT/gradlew" ] || [ -f "$REPO_ROOT/build.gradle" ] || [ -f "$REPO_ROOT/build.gradle.kts" ] || [ -f "$REPO_ROOT/settings.gradle" ] || [ -f "$REPO_ROOT/settings.gradle.kts" ]; then
  is_java=true
fi
if [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/requirements.txt" ] || [ -f "$REPO_ROOT/requirements-dev.txt" ] || [ -f "$REPO_ROOT/template.yaml" ]; then
  is_python=true
fi

# Allow manual override (useful in mixed repos / repos without manifests yet)
#   AI_SKILLS_STACK=java|python|all
stack="${AI_SKILLS_STACK:-}"

should_link_core_skill() {
  local skill="$1"

  # Always include orchestration + utilities
  case "$skill" in
    asulado-router|review|skill-sync|skill-creator|dev|planning|ai-setup) return 0 ;;
  esac

  if [ "$stack" = "all" ]; then
    return 0
  fi

  if [ "$stack" = "java" ] || { [ -z "$stack" ] && $is_java; }; then
    case "$skill" in
      dev-java|planning-java|agent-unit-tests) return 0 ;;
    esac
  fi

  if [ "$stack" = "python" ] || { [ -z "$stack" ] && $is_python; }; then
    case "$skill" in
      dev-python|planning-python) return 0 ;;
    esac
  fi

  return 1
}

link_dir() {
  local src="$1"
  local dest="$2"
  local abs_src
  abs_src="$(cd "$src" && pwd)"
  ln -s "$abs_src" "$dest"
}

# Core skills (from ai-kit), filtered by repo stack
if [ -d "$CORE_SKILLS_DIR" ]; then
  for skill_dir in "$CORE_SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    should_link_core_skill "$skill_name" || continue
    if [ -d "$LOCAL_SKILLS_DIR/$skill_name" ]; then
      continue
    fi
    link_dir "$skill_dir" "$OUT_DIR/$skill_name"
  done
fi

# Local overlay skills (repo-specific)
if [ -d "$LOCAL_SKILLS_DIR" ]; then
  for skill_dir in "$LOCAL_SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    link_dir "$skill_dir" "$OUT_DIR/$skill_name"
  done
fi

echo "build-skills: ready -> .ai/skills"
