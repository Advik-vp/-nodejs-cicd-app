#!/bin/bash
# Install development tools and extensions for VS Code CI/CD workflow

set -e

echo "=== Installing CI/CD Development Tools ==="

# Detect OS
OS_TYPE=$(uname -s)

# Install Node.js if not present
if ! command -v node &> /dev/null; then
  echo "Installing Node.js..."
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew install node@20
  elif [ "$OS_TYPE" = "Linux" ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
fi

# Install Git if not present
if ! command -v git &> /dev/null; then
  echo "Installing Git..."
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew install git
  elif [ "$OS_TYPE" = "Linux" ]; then
    sudo apt-get install -y git
  fi
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew install docker
  elif [ "$OS_TYPE" = "Linux" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
  fi
fi

# Install ACT for local GitHub Actions testing
if ! command -v act &> /dev/null; then
  echo "Installing ACT (local GitHub Actions runner)..."
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew install act
  elif [ "$OS_TYPE" = "Linux" ]; then
    curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
  fi
fi

# Install project dependencies
echo "Installing project dependencies..."
npm install

# Setup Git hooks
echo "Setting up Git hooks..."
npx husky install

echo "=== Installation Complete ==="
echo "✓ Node.js version: $(node --version)"
echo "✓ npm version: $(npm --version)"
echo "✓ Git version: $(git --version)"
echo "✓ Docker version: $(docker --version)"
echo "✓ ACT installed: $(act --version)"
echo ""
echo "Next steps:"
echo "1. Update .env with your configuration"
echo "2. Run: npm run dev"
echo "3. In another terminal: npm run test:watch"
echo "4. Test locally: act push -b"
