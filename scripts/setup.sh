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

# Optional: Local Linting environment
LINT_ENV_OK=true
printf "${CYAN}Optional (but required for CI Pipeline Pass): local linting python evironment with cvlint...${RESET}\n"
check_cmd python3.11
printf "${GREEN} ->${RESET} python3.11 found.\n"
if [ -d ".venv" ]; then
    printf "${GREEN} ->${RESET} .venv found.\n"

    if .venv/bin/python3.11 -c "import cvlint" >/dev/null 2>&1; then
        printf "${GREEN} ->${RESET} cvlint installed inside .venv.\n\n"
    else
        printf "${YELLOW} -> cvlint NOT installed inside .venv.${RESET}\n\n"
        LINT_ENV_OK=false
    fi
else
    printf "${YELLOW}No .venv/ directory detected.${RESET}\n\n"
    LINT_ENV_OK=false
fi

# Setup git hooks
printf "${CYAN}Configuring git hooks...${RESET}\n"
GIT_HOOKS_OK=true
git config core.hooksPath hooks

if [ -f hooks/commit-msg ]; then
  chmod +x hooks/commit-msg
  printf "${GREEN} ->${RESET} commit-msg hook enabled.\n"
else
  GIT_HOOKS_OK=false
  printf "${YELLOW} -> hooks/commit-msg not found.${RESET}\n"
fi


printf "\n${CYAN}-------------------------------------${RESET}\n"
printf "${CYAN}|        Environment Summary        |\n${RESET}"
printf "${CYAN}-------------------------------------${RESET}\n"

printf "${GREEN}✓ Required tools installed${RESET}\n"
printf "${GREEN}✓ Docker daemon running${RESET}\n"
if [ "$GIT_HOOKS_OK" = true ]; then
  printf "${GREEN}✓ Git hooks correclty configured${RESET}\n"
else
  printf "${YELLOW}⚠ Git hooks NOT correctly configured.\nCI will fail. Local dev is still possible.\n.${RESET}\n"
  printf 
fi

if [ "$LINT_ENV_OK" = true ]; then
  printf "${GREEN}✓ Local linting environment ready (.venv + cvlint)${RESET}\n"
else
  printf "${YELLOW}⚠ Local linting environment NOT set up${RESET}\n"
  printf "Local linting (via 'make lint') will not work until you create and activate a venv.\n\n"
  printf "  To enable, run:\n"
  printf "     python3.11 -m venv .venv\n"
  printf "     source .venv/bin/activate\n"
  printf "     pip install -r requirements.txt\n"
fi

printf "\n${GREEN}Setup complete.${RESET}\n\n"