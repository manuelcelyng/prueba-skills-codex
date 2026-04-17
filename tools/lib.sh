#!/usr/bin/env bash
# Shared utilities for ai-kit installer.
# Sourced by install.sh and workspace-install.sh.
# Bash 3.2+ compatible (no associative arrays, no readarray, no mapfile).

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Logging ─────────────────────────────────────────────────────────────────
log()  { printf "${GREEN}install:${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}install: WARNING:${NC} %s\n" "$*" >&2; }
err()  { printf "${RED}install: ERROR:${NC} %s\n" "$*" >&2; }

# ── Cleanup ─────────────────────────────────────────────────────────────────
# Call setup_cleanup after setting KIT_DIR to a tmpdir.
# The trap ensures the tmpdir is removed on exit (success or error).
setup_cleanup() {
  trap '_cleanup_tmpdir' EXIT
}

_cleanup_tmpdir() {
  if [ -n "${KIT_DIR:-}" ] && [ -d "${KIT_DIR:-}" ]; then
    rm -rf "$KIT_DIR"
  fi
}

# ── detect_stack ────────────────────────────────────────────────────────────
# Sets global variables: is_java, is_python, is_workspace
# Arguments: $1 = repo root path
detect_stack() {
  local repo_root="${1:-.}"

  is_java=false
  is_python=false
  is_workspace=false

  if [ -f "$repo_root/gradlew" ] \
    || [ -f "$repo_root/build.gradle" ] \
    || [ -f "$repo_root/build.gradle.kts" ] \
    || [ -f "$repo_root/settings.gradle" ] \
    || [ -f "$repo_root/settings.gradle.kts" ]; then
    is_java=true
  fi

  if [ -f "$repo_root/pyproject.toml" ] \
    || [ -f "$repo_root/requirements.txt" ] \
    || [ -f "$repo_root/requirements-dev.txt" ] \
    || [ -f "$repo_root/template.yaml" ]; then
    is_python=true
  fi

  # Workspace heuristic: non-git folder containing multiple git repos.
  if [ "${AI_SKILLS_WORKSPACE:-}" = "1" ] || [ "${AI_SKILLS_WORKSPACE:-}" = "true" ]; then
    is_workspace=true
  elif [ ! -d "$repo_root/.git" ]; then
    if find "$repo_root" -maxdepth 2 -mindepth 2 -name .git -type d -print -quit 2>/dev/null | grep -q .; then
      is_workspace=true
    fi
  fi
}

# ── should_include_skill ────────────────────────────────────────────────────
# Returns 0 (true) if the skill should be included for the current config.
# Arguments: $1 = skill name
# Reads globals: is_java, is_python, is_workspace, PROJECT, AI_SKILLS_STACK
should_include_skill() {
  local skill="$1"
  local stack="${AI_SKILLS_STACK:-}"

  # Always include orchestration + utilities + universal skills
  case "$skill" in
    ai-init-agents|review|skill-sync|skill-creator|ai-setup|azuredevops|postgres-qa-backup-restore|pr-description|caveman) return 0 ;;
  esac

  # Always include SDD generic skills (project-agnostic)
  case "$skill" in
    sdd-*) return 0 ;;
  esac

  # Project-specific always-included skills
  if [ "${PROJECT:-smartpay}" = "smartpay" ]; then
    case "$skill" in
      smartpay-sdd-orchestrator) return 0 ;;
      smartpay-workspace-router) $is_workspace && return 0 || return 1 ;;
    esac
  fi

  if [ "$stack" = "all" ]; then
    return 0
  fi

  if [ "$stack" = "java" ] || { [ -z "$stack" ] && $is_java; }; then
    case "$skill" in
      dev-java|planning-java|agent-unit-tests|gitlab-mr-review-java) return 0 ;;
    esac
  fi

  if [ "$stack" = "python" ] || { [ -z "$stack" ] && $is_python; }; then
    case "$skill" in
      dev-python|planning-python|gitlab-mr-review-python) return 0 ;;
    esac
  fi

  # Generic skills that don't match any category
  case "$skill" in
    dev|planning) return 0 ;;
  esac

  return 1
}
