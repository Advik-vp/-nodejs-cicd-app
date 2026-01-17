# CI/CD Pipeline - Complete Quick Reference

## Installation (5 minutes)

```bash
# Clone project
git clone https://github.com/your-org/nodejs-cicd-app
cd nodejs-cicd-app

# Install everything
bash scripts/quickstart.sh

# For Windows, use Git Bash or:
npm install
npx husky install
cp .env.example .env
```

## Daily Commands

```bash
# Development
npm run dev              # Start app with auto-reload
npm run test:watch      # Run tests in watch mode

# Before committing
npm run lint:fix        # Auto-fix linting issues
npm run format          # Auto-format code
npm run test            # Run full test suite

# Verify everything
npm run build           # Run complete CI pipeline locally

# Docker testing
npm run docker:build    # Build container
npm run docker:run      # Run container
curl http://localhost:3000/health  # Test health endpoint
```

## GitHub Setup (One-time)

1. **Create GitHub Account** & repository
2. **Add Secrets** (Settings → Secrets):
   - `DATABASE_URL` - Production database connection
   - `SLACK_WEBHOOK` - Slack notifications
   - `API_SECRET` - API authentication key

3. **Enable Workflows** - Go to Actions tab, enable workflows if disabled

4. **Commit & Push**:
   ```bash
   git add .
   git commit -m "feat: initial ci/cd setup"
   git push origin main
   ```

## Workflow (Per feature)

```bash
# Create branch
git checkout -b feature/my-feature

# Make changes & test locally
npm run dev
npm run test:watch

# Commit when satisfied
git add .
git commit -m "feat: add feature"
git push origin feature/my-feature

# Create PR on GitHub
# Wait for automated checks
# Request code review
# After approval, merge to develop
# After testing, merge to main for production
```

## Common Issues & Fixes

```bash
# Tests failing locally but passing in CI
npm run test -- --forceExit  # Force Node exit after tests

# Linting errors
npm run lint:fix             # Auto-fix most errors

# Docker build issues
docker system prune -a       # Clean Docker cache
npm run docker:build         # Rebuild

# Port already in use
lsof -i :3000                # Find process on port 3000
kill -9 <PID>               # Kill it

# Database connection issues
psql postgresql://user:pass@localhost:5432/db  # Test connection

# Can't find .env file
cp .env.example .env        # Create from example
```

## VS Code Extensions

Install these for best experience:

- **GitHub Copilot** - AI code suggestions
- **ESLint** - Real-time linting
- **Prettier** - Code formatter
- **Jest** - Test runner UI
- **Docker** - Container management
- **GitHub Actions** - Workflow editing
- **GitLens** - Git insights

## Project Structure

```
sample-nodejs-app/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml              # Main CI/CD pipeline
│       ├── docker-publish.yml      # Container publishing
│       └── code-analysis.yml       # Security scanning
├── src/
│   └── index.js                    # Application entry point
├── tests/
│   └── index.test.js               # Test suite
├── scripts/
│   ├── quickstart.sh               # 5-minute setup
│   ├── local-ci.sh                 # Run CI locally
│   └── setup.sh                    # Initial setup
├── Dockerfile                      # Container definition
├── docker-compose.yml              # Local services
├── package.json                    # Project manifest
├── .eslintrc.json                  # Linting rules
├── .prettierrc.json                # Formatting rules
├── jest.config.js                  # Test config
└── .env.example                    # Environment template
```

## Environment Variables Quick Ref

```bash
# Development (.env)
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
DATABASE_URL=postgresql://localhost/appdb

# Production (GitHub Secrets)
NODE_ENV=production
PORT=3000
LOG_LEVEL=warn
DATABASE_URL=<encrypted-prod-url>
API_SECRET=<encrypted-secret>
```

## Testing Quick Ref

```bash
npm run test                    # Run all tests once
npm run test:watch             # Watch for changes
npm run test -- --coverage     # Generate coverage report
npm run test -- specific.test  # Run specific test file

# Coverage targets
Branches: 70%
Functions: 70%
Lines: 70%
Statements: 70%
```

## Docker Quick Ref

```bash
npm run docker:build           # Build: app:latest
npm run docker:run             # Run on localhost:3000
docker tag app:latest my-app:1.0  # Tag image
docker push my-app:1.0         # Push to registry
docker logs app-container      # View logs
docker exec app-container sh   # Shell into container
```

## Deployment Branches

| Branch | Environment | Trigger | Approval |
|--------|-------------|---------|----------|
| `develop` | Staging | Auto on push | Automated tests |
| `main` | Production | Auto on push | Manual approval |
| `hotfix/*` | Production | Manual trigger | Manual approval |

## Monitoring Links

- **GitHub Actions**: https://github.com/YOUR-ORG/YOUR-REPO/actions
- **Coverage Reports**: https://codecov.io/gh/YOUR-ORG/YOUR-REPO
- **Docker Images**: https://ghcr.io/YOUR-ORG/YOUR-REPO
- **Live App**: https://your-domain.com/health

## Getting Help

```bash
# Check Node version
node --version

# Check npm version
npm --version

# See all npm scripts
npm run

# Validate workflow syntax
act -l

# Run specific workflow job locally
act -j quality
```

## Key Metrics & Goals

- **Build Time**: < 5 minutes
- **Test Coverage**: > 70%
- **Deployment Time**: < 10 minutes
- **Uptime**: > 99.9%
- **Security Vulnerabilities**: 0 critical

## Quick Links

- 📖 Full Setup: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- 🐛 Troubleshooting: [VALIDATION_AND_TROUBLESHOOTING.md](VALIDATION_AND_TROUBLESHOOTING.md)
- ⚙️ Advanced: [ADVANCED_ENHANCEMENTS.md](ADVANCED_ENHANCEMENTS.md)
- 📋 Configuration: [CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)

**Last Updated**: January 2024  
**Status**: Production Ready ✅
