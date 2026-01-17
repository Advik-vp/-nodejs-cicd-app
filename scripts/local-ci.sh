#!/bin/bash

# Local CI pipeline script - mimics GitHub Actions locally
# Run this before pushing to verify everything works

set -e

echo "=== Starting Local CI Pipeline ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}✗ $1 is not installed${NC}"
    exit 1
  fi
  echo -e "${GREEN}✓ $1 found${NC}"
}

echo -e "${YELLOW}Checking prerequisites...${NC}"
check_command node
check_command npm
check_command git

echo -e "\n${YELLOW}Installing dependencies...${NC}"
npm ci

echo -e "\n${YELLOW}Running linter...${NC}"
npm run lint || exit 1

echo -e "\n${YELLOW}Checking code format...${NC}"
npm run format:check || exit 1

echo -e "\n${YELLOW}Running unit tests...${NC}"
npm run test || exit 1

echo -e "\n${YELLOW}Building Docker image...${NC}"
docker build -t app:test . || exit 1

echo -e "\n${GREEN}=== All checks passed! ===${NC}"
echo -e "${GREEN}Ready to push to repository${NC}"
