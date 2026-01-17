#!/bin/bash
# Setup script for initial project configuration

set -e

echo "=== CI/CD Project Setup ==="

# Install Node dependencies
echo "Installing dependencies..."
npm install

# Setup Git hooks
echo "Setting up Git hooks..."
npx husky install

npx husky add .husky/pre-commit "npm run lint && npm run format:check"
npx husky add .husky/pre-push "npm run test"

# Create .env file from example
if [ ! -f .env ]; then
  echo "Creating .env file..."
  cp .env.example .env
  echo "⚠️  Update .env with your actual values"
fi

# Install Docker (if not present)
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  if [ "$OSTYPE" == "linux-gnu"* ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
  elif [ "$OSTYPE" == "darwin"* ]; then
    brew install docker
  fi
fi

echo "=== Setup complete ==="
echo "Next steps:"
echo "1. Update .env with your configuration"
echo "2. Run: npm run dev"
echo "3. In another terminal: npm run test:watch"
echo "4. Commit and push to trigger CI/CD pipeline"
