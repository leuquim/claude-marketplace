#!/bin/bash

# Git Worktree Manager
# Handles creating, listing, switching, and cleaning up Git worktrees
# Non-interactive version for Claude automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get repo root
GIT_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$GIT_ROOT/.worktrees"

# Ensure .worktrees is in .gitignore
ensure_gitignore() {
  if ! grep -q "^\.worktrees$" "$GIT_ROOT/.gitignore" 2>/dev/null; then
    echo ".worktrees" >> "$GIT_ROOT/.gitignore"
  fi
}

# Create a new worktree (non-interactive)
create_worktree() {
  local branch_name="$1"
  local from_branch="${2:-main}"

  if [[ -z "$branch_name" ]]; then
    echo -e "${RED}Error: Branch name required${NC}"
    exit 1
  fi

  local worktree_path="$WORKTREE_DIR/$branch_name"

  # Check if worktree already exists
  if [[ -d "$worktree_path" ]]; then
    echo -e "${YELLOW}Worktree already exists at: $worktree_path${NC}"
    echo "EXISTING:$worktree_path"
    exit 0
  fi

  echo -e "${BLUE}Creating worktree: $branch_name${NC}"
  echo "  From: $from_branch"
  echo "  Path: $worktree_path"

  # Update base branch
  echo -e "${BLUE}Updating $from_branch...${NC}"
  git fetch origin "$from_branch" 2>/dev/null || true

  # Create worktree
  mkdir -p "$WORKTREE_DIR"
  ensure_gitignore

  echo -e "${BLUE}Creating worktree...${NC}"
  git worktree add -b "$branch_name" "$worktree_path" "origin/$from_branch"

  echo -e "${GREEN}✓ Worktree created successfully!${NC}"
  echo "CREATED:$worktree_path"
}

# List all worktrees
list_worktrees() {
  echo -e "${BLUE}Available worktrees:${NC}"
  echo ""

  if [[ ! -d "$WORKTREE_DIR" ]]; then
    echo -e "${YELLOW}No worktrees found${NC}"
    return
  fi

  local count=0
  for worktree_path in "$WORKTREE_DIR"/*; do
    if [[ -d "$worktree_path" && -d "$worktree_path/.git" ]]; then
      count=$((count + 1))
      local worktree_name=$(basename "$worktree_path")
      local branch=$(git -C "$worktree_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

      if [[ "$PWD" == "$worktree_path" ]]; then
        echo -e "${GREEN}✓ $worktree_name${NC} (current) → branch: $branch"
      else
        echo -e "  $worktree_name → branch: $branch"
      fi
    fi
  done

  if [[ $count -eq 0 ]]; then
    echo -e "${YELLOW}No worktrees found${NC}"
  else
    echo ""
    echo -e "${BLUE}Total: $count worktree(s)${NC}"
  fi

  echo ""
  echo -e "${BLUE}Main repository:${NC}"
  local main_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  echo "  Branch: $main_branch"
  echo "  Path: $GIT_ROOT"
}

# Check if worktree exists, return path if so
check_worktree() {
  local worktree_name="$1"
  local worktree_path="$WORKTREE_DIR/$worktree_name"

  if [[ -d "$worktree_path" ]]; then
    echo "EXISTS:$worktree_path"
  else
    echo "NOT_FOUND"
  fi
}

# Get current branch name
current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

# Get default branch (main or master)
default_branch() {
  if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
    echo "main"
  elif git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
    echo "master"
  else
    echo "main"
  fi
}

# Clean up a specific worktree (non-interactive)
remove_worktree() {
  local worktree_name="$1"
  local worktree_path="$WORKTREE_DIR/$worktree_name"

  if [[ ! -d "$worktree_path" ]]; then
    echo -e "${RED}Error: Worktree not found: $worktree_name${NC}"
    exit 1
  fi

  # Check if current directory
  if [[ "$PWD" == "$worktree_path"* ]]; then
    echo -e "${RED}Error: Cannot remove current worktree. Change directory first.${NC}"
    exit 1
  fi

  git worktree remove "$worktree_path" --force 2>/dev/null || true
  echo -e "${GREEN}✓ Removed: $worktree_name${NC}"

  # Clean up empty directory if nothing left
  if [[ -z "$(ls -A "$WORKTREE_DIR" 2>/dev/null)" ]]; then
    rmdir "$WORKTREE_DIR" 2>/dev/null || true
  fi
}

# Clean up all inactive worktrees (non-interactive)
cleanup_worktrees() {
  if [[ ! -d "$WORKTREE_DIR" ]]; then
    echo -e "${YELLOW}No worktrees to clean up${NC}"
    return
  fi

  echo -e "${BLUE}Cleaning up inactive worktrees...${NC}"

  local removed=0
  for worktree_path in "$WORKTREE_DIR"/*; do
    if [[ -d "$worktree_path" && -d "$worktree_path/.git" ]]; then
      local worktree_name=$(basename "$worktree_path")

      # Skip if current worktree
      if [[ "$PWD" == "$worktree_path"* ]]; then
        echo -e "${YELLOW}(skip) $worktree_name - currently active${NC}"
        continue
      fi

      git worktree remove "$worktree_path" --force 2>/dev/null || true
      echo -e "${GREEN}✓ Removed: $worktree_name${NC}"
      removed=$((removed + 1))
    fi
  done

  # Clean up empty directory if nothing left
  if [[ -z "$(ls -A "$WORKTREE_DIR" 2>/dev/null)" ]]; then
    rmdir "$WORKTREE_DIR" 2>/dev/null || true
  fi

  echo -e "${GREEN}Cleanup complete! Removed $removed worktree(s)${NC}"
}

# Main command handler
main() {
  local command="${1:-list}"

  case "$command" in
    create)
      create_worktree "$2" "$3"
      ;;
    list|ls)
      list_worktrees
      ;;
    check)
      check_worktree "$2"
      ;;
    current-branch)
      current_branch
      ;;
    default-branch)
      default_branch
      ;;
    remove)
      remove_worktree "$2"
      ;;
    cleanup|clean)
      cleanup_worktrees
      ;;
    help)
      show_help
      ;;
    *)
      echo -e "${RED}Unknown command: $command${NC}"
      echo ""
      show_help
      exit 1
      ;;
  esac
}

show_help() {
  cat << EOF
Git Worktree Manager (Non-Interactive)

Usage: worktree-manager.sh <command> [options]

Commands:
  create <branch-name> [from-branch]  Create new worktree (from-branch defaults to main)
  list | ls                           List all worktrees
  check <name>                        Check if worktree exists, return path
  current-branch                      Get current branch name
  default-branch                      Get default branch (main or master)
  remove <name>                       Remove specific worktree
  cleanup | clean                     Remove all inactive worktrees
  help                                Show this help message

Examples:
  worktree-manager.sh create feature-login main
  worktree-manager.sh check feature-login
  worktree-manager.sh remove feature-login
  worktree-manager.sh list

EOF
}

# Run
main "$@"
