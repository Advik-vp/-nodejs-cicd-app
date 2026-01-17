# Validation & Troubleshooting Guide

## Validation Checklist

### ✓ Pre-Commit Validation

Run before pushing code:

```bash
# 1. Local quality checks
npm run lint          # Should pass with 0 errors
npm run format:check  # Should pass formatting check
npm run test          # Should pass with 70%+ coverage

# 2. Docker build test
npm run docker:build  # Should build successfully

# 3. Git status
git status            # Should only show intended changes
```

### ✓ GitHub Actions Validation

After pushing, verify in GitHub:

1. Go to **Actions** tab in your repository
2. Click the latest workflow run
3. Verify all jobs pass:
   - ✅ Quality checks (linting, formatting)
   - ✅ Unit tests
   - ✅ Build & security scan
   - ✅ Integration tests
   - ✅ Deployment (if applicable)

### ✓ Manual Deployment Validation

After deployment to staging/production:

```bash
# Health check endpoint
curl -X GET https://your-domain.com/health

# Expected response:
# {
#   "status": "ok",
#   "timestamp": "2024-01-17T10:30:00.000Z"
# }

# API endpoint test
curl -X GET https://your-domain.com/api/users

# Database connectivity check
npm run migrate:status  # (if using migrations)
```

---

## Common Issues & Solutions

### Issue 1: Local tests pass, but CI/CD fails

**Symptoms:**
- Tests pass locally: `npm run test` ✅
- GitHub Actions fails: ❌

**Root Causes:**
- Different Node versions locally vs CI
- Uncommitted changes
- Environment variables missing
- Mock data differences

**Solutions:**

```bash
# 1. Verify Node version matches
node --version  # Should be v20.x.x

# 2. Check git status
git status
git add -A
git commit -m "fix: add missing files"

# 3. Test with exact CI environment
docker run -it node:20-alpine node --version

# 4. Check .env variables
cat .env  # Verify all required vars are set
```

### Issue 2: Docker build fails in CI but works locally

**Symptoms:**
- `npm run docker:build` works locally
- GitHub Actions fails at "Build Docker image" step

**Root Causes:**
- `.dockerignore` missing files
- Node modules cached differently
- Platform-specific line endings (CRLF vs LF)

**Solutions:**

```bash
# 1. Check .dockerignore
cat .dockerignore

# 2. Clean Docker cache
docker system prune -a

# 3. Rebuild without cache
docker build --no-cache -t app:latest .

# 4. Check line endings (Windows)
git config --global core.autocrlf false
git config --global core.eol lf
```

### Issue 3: Tests fail with database connection errors

**Symptoms:**
- Error: "connect ECONNREFUSED 127.0.0.1:5432"
- Tests expect real database

**Solutions:**

```bash
# 1. Start PostgreSQL service
docker run -d --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine

# 2. Update .env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/testdb

# 3. Or mock database in tests
npm run test -- --testEnvironment=node

# 4. Use in-memory database
# Install: npm install --save-dev sqlite3
# Configure jest.config.js to use :memory:
```

### Issue 4: ESLint fails with formatting errors

**Symptoms:**
- Error: "Expected indentation of 2 spaces but found 4"
- Too many errors to fix manually

**Solutions:**

```bash
# Auto-fix all ESLint issues
npm run lint:fix

# Auto-format code with Prettier
npm run format

# Run both together
npm run lint:fix && npm run format

# Check what Prettier would change
npm run format:check
```

### Issue 5: GitHub Actions workflow not triggering

**Symptoms:**
- Push code but Actions don't run
- No jobs in Actions tab

**Root Causes:**
- Workflow file syntax error
- Workflow not enabled in settings
- File not in correct path: `.github/workflows/`
- Branch protection rules blocking

**Solutions:**

```bash
# 1. Validate workflow syntax
npm install -g @actions/core
# Or use online tool: https://rhysd.github.io/actionlint/

# 2. Check branch rules
# Settings → Rules → Branch protection rules
# Ensure workflow isn't blocked

# 3. Enable workflow
# Go to Actions tab → Click disabled workflow → Enable

# 4. Verify file location
ls -la .github/workflows/
# Should show: ci-cd.yml, docker-publish.yml, code-analysis.yml

# 5. Re-run workflow
# Actions tab → Select workflow → Re-run jobs
```

### Issue 6: Secrets not available in workflow

**Symptoms:**
- Error: "variable is undefined"
- Workflow can't access ${{ secrets.DATABASE_URL }}

**Solutions:**

```bash
# 1. Add secret to GitHub
# Settings → Secrets and variables → Actions → New repository secret

# 2. Reference correctly in workflow
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}

# 3. Verify secret is accessible
# Settings → Secrets and variables → Actions
# Check secret name matches exactly (case-sensitive)

# 4. Check job permissions
permissions:
  contents: read
  packages: write
```

### Issue 7: Coverage thresholds failing

**Symptoms:**
- Error: "Coverage for statements: 65% < 70% threshold"
- Tests pass individually but fail coverage check

**Solutions:**

```bash
# 1. Generate coverage report
npm run test -- --coverage

# 2. View coverage details
cat coverage/lcov-report/index.html  # Open in browser

# 3. Identify uncovered lines
# Look for red lines in coverage report

# 4. Either:
# a) Write more tests to improve coverage
# b) Lower coverage threshold in jest.config.js
#    (Not recommended for production)

# 5. Re-run test with coverage report
npm run test
```

### Issue 8: Deployment fails with "health check failed"

**Symptoms:**
- Error: "curl: (7) Failed to connect"
- Application deployed but not accessible

**Solutions:**

```bash
# 1. Verify container is running
docker ps
docker logs app-container

# 2. Check port binding
docker port app-container

# 3. Test health endpoint directly
curl -v http://localhost:3000/health

# 4. Check firewall
# Windows: Check Windows Defender firewall
# Linux: Check UFW: sudo ufw allow 3000

# 5. Verify application startup
docker logs -f app-container
# Look for "Server running on http://localhost:3000"

# 6. Update health check timeout in Dockerfile if needed
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

---

## Debug Workflow Locally with ACT

### Run workflow step-by-step

```bash
# Install ACT: https://github.com/nektos/act

# List all available jobs
act -l

# Run specific job with debug output
act -j quality -v

# Run with secrets
act -s SLACK_WEBHOOK=xxx -s DATABASE_URL=yyy

# Run single step
act -l | grep "quality"
act -j quality --list

# Simulate different events
act push          # Simulate push event
act pull_request  # Simulate PR event
act schedule      # Simulate scheduled run
```

### Example: Debug CI job locally

```bash
# 1. Install ACT
brew install act  # macOS
choco install act # Windows

# 2. Create local secrets file (.env for ACT)
cat > .actrc << EOF
-P ubuntu-latest=ghcr.io/catthehacker/ubuntu:full-latest
-s SLACK_WEBHOOK=http://localhost:9090/webhook
-s DATABASE_URL=postgresql://test:test@localhost:5432/testdb
EOF

# 3. Run specific workflow job
act -j quality --debug

# 4. Watch for errors and fix locally
npm run lint      # If quality job fails
npm run test      # If test job fails
```

---

## Performance Optimization

### Speed up CI/CD pipeline

```yaml
# In .github/workflows/ci-cd.yml

# 1. Cache dependencies
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'    # This saves ~30 seconds per run

# 2. Run jobs in parallel (already configured)
jobs:
  quality:
    runs-on: ubuntu-latest  # Runs simultaneously
  test:
    runs-on: ubuntu-latest  # Runs simultaneously
  build:
    needs: [quality, test]  # Waits for above, then runs

# 3. Cancel in-progress runs
# Settings → Actions → General → Concurrency
```

### Reduce Docker image size

```dockerfile
# Multi-stage build (already in Dockerfile)
FROM node:20-alpine AS builder   # Smaller base image
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine              # Start fresh, excludes build dependencies
COPY --from=builder /app/node_modules ./node_modules
```

---

## Monitoring & Alerts

### GitHub Actions Notifications

1. **Enable email notifications:**
   - Settings → Notifications → Check "Actions"

2. **Slack integration:**
   ```yaml
   - uses: slackapi/slack-github-action@v1
     with:
       payload: |
         {"text": "Pipeline: ${{ job.status }}"}
     env:
       SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
   ```

3. **Custom status badge in README:**
   ```markdown
   ![CI/CD Status](https://github.com/YOU/REPO/actions/workflows/ci-cd.yml/badge.svg)
   ```

### Manual Health Checks

```bash
# Scheduled check script (cron)
0 9 * * 1 ./scripts/health-check.sh  # Mondays at 9 AM

# health-check.sh content
#!/bin/bash
curl -f https://your-domain.com/health || \
  echo "ALERT: Health check failed" | mail -s "Prod Alert" ops@company.com
```

---

## Security Best Practices

### 1. Secret Management

```bash
# ✅ DO: Use GitHub secrets
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}

# ❌ DON'T: Hardcode secrets
env:
  DB_PASSWORD: "password123"

# ✅ DO: Rotate secrets regularly
# Every 90 days: Settings → Secrets → Update value

# ❌ DON'T: Log secrets
- run: echo ${{ secrets.DB_PASSWORD }}  # WRONG!

# ✅ DO: Mask secrets in logs
- run: |
    echo "::add-mask::${{ secrets.DB_PASSWORD }}"
    npm run test
```

### 2. Branch Protection

```yaml
# Settings → Branches → Branch protection rules

Required:
✅ Require a pull request before merging
✅ Require status checks to pass before merging
✅ Require branches to be up to date
✅ Require code reviews before merging
✅ Require conversation resolution
```

### 3. Dependency Scanning

```bash
# Regular audits
npm audit                    # Check for vulnerabilities
npm audit fix               # Auto-fix where possible

# Automated checks (in CI)
npm audit --audit-level=moderate  # Fail on moderate+ severity

# Snyk integration (optional)
npm install -g snyk
snyk auth
snyk test
```

---

## Rollback Procedures

### Rollback Docker image

```bash
# If latest deployment is broken:

# 1. Get previous image tag
docker images | grep app  # Find previous version

# 2. Re-deploy previous image
docker tag app:v1.0.0 app:latest
docker push app:latest

# 3. Or trigger previous GitHub Actions run
# Actions → Select previous successful run → Re-run jobs
```

### Database rollback

```bash
# If migrations break production:

# 1. Stop application
docker stop app-container

# 2. Rollback migrations
npm run migrate:down

# 3. Restart application
docker start app-container

# 4. Verify
curl https://your-domain.com/health
```

---

## Getting Help

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Act Documentation:** https://github.com/nektos/act
- **Node.js Best Practices:** https://nodejs.org/en/docs/guides/nodejs-performance/
- **Docker Best Practices:** https://docs.docker.com/develop/dev-best-practices/
