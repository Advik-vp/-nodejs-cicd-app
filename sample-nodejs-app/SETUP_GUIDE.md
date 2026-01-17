# CI/CD Setup & Installation Guide

## Prerequisites Installation

### 1. System Requirements

**Windows:**
```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install prerequisites
choco install nodejs git docker-desktop
```

**macOS:**
```bash
brew install node@20 git docker
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y nodejs npm git docker.io docker-compose
sudo usermod -aG docker $USER
```

### 2. VS Code Extensions

Install these extensions in VS Code for optimal workflow:

```
code --install-extension GitHub.copilot
code --install-extension eamodio.gitlens
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension orta.vscode-jest
code --install-extension Docker
code --install-extension ms-azuretools.vscode-docker
code --install-extension GitHub.vscode-pull-request-github
code --install-extension GitHub.vscode-github-actions
```

Or install from VS Code UI: Extensions → Search by extension name

### 3. Project Setup

```bash
# Clone and initialize
git clone https://github.com/YOUR-USERNAME/nodejs-cicd-app.git
cd nodejs-cicd-app

# Run setup script
bash scripts/setup.sh  # On Windows: use Git Bash

# Or manual setup
npm install
npx husky install
```

## Local Development Workflow

### Run Application

```bash
# Development mode (with auto-reload)
npm run dev

# Production build test
npm run build
npm start
```

### Code Quality & Testing

```bash
# Lint code
npm run lint
npm run lint:fix       # Auto-fix issues

# Format code
npm run format
npm run format:check   # Check without modifying

# Run tests
npm run test           # Run once
npm run test:watch     # Watch mode
```

### Docker Local Testing

```bash
# Build image
npm run docker:build

# Run container
npm run docker:run

# Test container
curl http://localhost:3000/health

# Stop container
docker stop $(docker ps -q --filter ancestor=app:latest)
```

## Secrets Management

### 1. GitHub Secrets Setup

For production deployments, add secrets to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

Required secrets:
```
SLACK_WEBHOOK        # For notifications
SONAR_TOKEN          # For code analysis
DOCKER_REGISTRY_PAT  # For image registry
DATABASE_URL         # Production database
API_SECRET           # API authentication key
```

### 2. Local Environment Variables

Create `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
# Edit .env with local values
```

Never commit `.env` to version control.

## Running Workflows Locally

### Option A: Using ACT (Simulate GitHub Actions)

```bash
# Install ACT
choco install act  # Windows
brew install act   # macOS
# Or: https://github.com/nektos/act/releases

# Run workflow
act push -b                    # Simulate push event
act pull_request -b            # Simulate PR event
act -l                         # List all workflows

# Run specific workflow
act -j quality                 # Run 'quality' job

# See logs
act -v                         # Verbose output
```

### Option B: Manual Pipeline Execution

```bash
# Execute local CI script
bash scripts/local-ci.sh

# Step by step
npm run lint
npm run format:check
npm run test
npm run docker:build
```

## Quality Gates Configuration

### Coverage Thresholds (jest.config.js)

```javascript
coverageThreshold: {
  global: {
    branches: 70,      // 70% branch coverage required
    functions: 70,     // 70% function coverage required
    lines: 70,         // 70% line coverage required
    statements: 70     // 70% statement coverage required
  }
}
```

Adjust based on your project's quality standards.

### ESLint Rules (.eslintrc.json)

Key rules enforced:
- `no-console`: Prevents debugging logs in production
- `no-unused-vars`: Catches unused variables
- `no-var`: Enforces const/let usage
- Airbnb style guide compliance

## Common Workflows

### 1. Feature Development

```bash
git checkout -b feature/my-feature
# ... make changes ...
npm run lint:fix          # Auto-fix formatting
npm run test              # Verify tests pass
git add .
git commit -m "feat: describe change"
git push origin feature/my-feature
# Create Pull Request on GitHub
```

### 2. Code Review & Merge

When PR is created:
- Automated checks run (linting, tests, security)
- Request code review from team
- After approval, merge to develop
- Automated deployment to staging

### 3. Release to Production

```bash
git checkout main
git pull origin develop
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
# Automated workflow triggers:
# - Build & test
# - Create Docker image
# - Deploy to production
```

## Environment-Specific Configuration

### Development (.env)
```
NODE_ENV=development
LOG_LEVEL=debug
DATABASE_URL=postgresql://localhost/appdb
```

### Staging (GitHub Secrets)
```
NODE_ENV=staging
LOG_LEVEL=info
DATABASE_URL=<staging-db-url>
```

### Production (GitHub Secrets + Manual)
```
NODE_ENV=production
LOG_LEVEL=warn
DATABASE_URL=<production-db-url>
```

## Database Migrations (Optional)

If using database migrations with tools like Knex or TypeORM:

```bash
# Create migration
npm run migrate:create -- create_users_table

# Run migrations
npm run migrate:up

# Rollback
npm run migrate:down
```

In CI/CD pipeline (add to `.github/workflows/ci-cd.yml`):

```yaml
- name: Run database migrations
  run: npm run migrate:up
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## Container Registry Setup (Optional)

### GitHub Container Registry (GHCR)

1. Create Personal Access Token:
   - GitHub Settings → Developer settings → Personal access tokens → Generate new token
   - Scope: `write:packages`, `read:packages`, `delete:packages`

2. Login locally:
   ```bash
   docker login ghcr.io -u USERNAME -p TOKEN
   ```

3. Tag and push:
   ```bash
   docker tag app:latest ghcr.io/username/app:latest
   docker push ghcr.io/username/app:latest
   ```

### Docker Hub

```bash
docker login -u USERNAME
docker tag app:latest username/app:latest
docker push username/app:latest
```

## Pre-commit & Pre-push Hooks

Husky automatically runs checks before commits:

```bash
git commit -m "fix: issue"
# Automatically runs: npm run lint && npm run format:check
# If failed, commit blocked until fixed
```

To skip hooks (not recommended):
```bash
git commit --no-verify
```

## Troubleshooting Common Issues

See the main **VALIDATION_AND_TROUBLESHOOTING.md** document for detailed troubleshooting steps.
