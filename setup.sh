#!/bin/sh
set -e

# ANSI colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo
printf "${CYAN}Running initial setup for resume repo...${RESET}\n"

# Ensure in a git repo
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  printf "${RED}Error: not inside a Git repository.${RESET}\n"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
printf "${GREEN} ->${RESET} Repo root: $REPO_ROOT\n\n"

# Required tools check
check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf "${RED}Error: '$1' is required but not installed.${RESET}\n"
    exit 1
  fi
}

printf "${CYAN}Checking required commands...${RESET}\n"
check_cmd git
check_cmd make
check_cmd docker
printf "${GREEN} ->${RESET} git, make, docker found.\n\n"

# Docker daemon running?
printf "${CYAN}Checking Docker daemon...${RESET}\n"
if ! docker info >/dev/null 2>&1; then
  printf "${RED}Error: Docker daemon is not running.${RESET}\n"
  printf "Start Docker Desktop (or your Docker service) and rerun this script.\n"
  exit 1
fi
printf "${GREEN} ->${RESET} Docker daemon is running.\n\n"

# Setup git hooks
printf "${CYAN}Configuring git hooks...${RESET}\n"
git config core.hooksPath hooks

if [ -f hooks/commit-msg ]; then
  chmod +x hooks/commit-msg
  printf "${GREEN} ->${RESET} commit-msg hook enabled.\n"
else
  printf "${YELLOW}Warning:${RESET} hooks/commit-msg not found. CI may fail without this. Try pulling the latest repo again.\n"
fi

echo
printf "${GREEN}Setup complete.${RESET}\n"