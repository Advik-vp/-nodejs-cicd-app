#!/usr/bin/env bash
# Quick start script - gets you running in 5 minutes

set -e

echo "🚀 CI/CD Quick Start"
echo "===================="

# Check prerequisites
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Install from https://nodejs.org/"
  exit 1
fi

if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Install from https://docker.com"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "❌ Git not found. Install from https://git-scm.com"
  exit 1
fi

echo "✅ All prerequisites installed"
echo ""

# Install project
echo "📦 Installing dependencies..."
npm install > /dev/null 2>&1

# Setup env
if [ ! -f .env ]; then
  echo "🔐 Creating .env file..."
  cp .env.example .env
fi

# Setup git hooks
echo "🔗 Setting up Git hooks..."
npx husky install > /dev/null 2>&1

# Run tests
echo "🧪 Running tests..."
npm run test > /dev/null 2>&1 || true

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update .env with your configuration"
echo "   2. Start dev server: npm run dev"
echo "   3. In another terminal: npm run test:watch"
echo "   4. Test locally with: act push -b"
echo ""
echo "📚 Documentation:"
echo "   - Setup guide: SETUP_GUIDE.md"
echo "   - Troubleshooting: VALIDATION_AND_TROUBLESHOOTING.md"
echo "   - Advanced features: ADVANCED_ENHANCEMENTS.md"
