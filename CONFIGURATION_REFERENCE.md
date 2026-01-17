# Configuration Reference Guide

## Environment Variables

### Development (`.env`)
```bash
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
DATABASE_URL=postgresql://user:password@localhost:5432/appdb
API_SECRET=dev-secret-key
```

### Staging (GitHub Secrets)
```
NODE_ENV=staging
PORT=3000
LOG_LEVEL=info
DATABASE_URL=<staging-db-connection-string>
API_SECRET=<staging-api-secret>
SLACK_WEBHOOK=<webhook-url>
```

### Production (GitHub Secrets - Encrypted)
```
NODE_ENV=production
PORT=3000
LOG_LEVEL=warn
DATABASE_URL=<prod-db-connection-string>
API_SECRET=<prod-api-secret>
SLACK_WEBHOOK=<webhook-url>
DOCKER_REGISTRY_PAT=<token>
```

---

## GitHub Actions Secrets Setup

Navigate to: **Repository Settings → Secrets and variables → Actions**

### Essential Secrets

| Secret | Purpose | Example |
|--------|---------|---------|
| `DATABASE_URL` | Production database connection | `postgresql://user:pass@host:5432/db` |
| `API_SECRET` | JWT/API authentication key | `your-256-bit-secret-key` |
| `SLACK_WEBHOOK` | Slack notifications | `https://hooks.slack.com/services/T.../B.../X...` |
| `SONAR_TOKEN` | SonarCloud analysis token | `squ_xxxxxxxxxxxxx` |
| `DOCKER_REGISTRY_PAT` | Docker Hub/GHCR token | `ghp_xxxxxxxxxxxxx` |

### Setting Up Slack Webhook

1. Go to https://api.slack.com/apps
2. Create New App → From scratch
3. Enable Incoming Webhooks
4. Add New Webhook to Workspace
5. Copy webhook URL to GitHub Secrets as `SLACK_WEBHOOK`

### Setting Up SonarCloud Token

1. Go to https://sonarcloud.io/
2. Sign up with GitHub
3. Create organization and project
4. Go to Security → Tokens → Generate token
5. Copy to GitHub Secrets as `SONAR_TOKEN`

---

## Workflow Customization

### Add new quality gate

```yaml
# In .github/workflows/ci-cd.yml
  quality:
    steps:
      - name: Run custom linter
        run: npm run custom:lint
        continue-on-error: false  # Fail if this fails
```

### Modify notification triggers

```yaml
- name: Slack notification
  if: always()  # Always notify
  # if: failure()  # Only notify on failure
  # if: success()  # Only notify on success
```

### Adjust timeout limits

```yaml
jobs:
  build:
    timeout-minutes: 20  # Job timeout
```

---

## Docker Hub Configuration (Optional)

If using Docker Hub instead of GHCR:

1. Login:
   ```bash
   docker login -u USERNAME
   ```

2. Update `.github/workflows/docker-publish.yml`:
   ```yaml
   env:
     REGISTRY: docker.io
     IMAGE_NAME: username/app
   ```

3. Add secret `DOCKER_USERNAME` and `DOCKER_PASSWORD`

---

## Advanced Configurations

### Matrix Strategy (Test Multiple Versions)

```yaml
test:
  strategy:
    matrix:
      node-version: [18.x, 20.x, 21.x]
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
```

### Conditional Jobs

```yaml
deploy:
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Concurrent Job Limits

Settings → Actions → General → Concurrency:
```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

---

## Common Customizations by Stack

### Python Project

**Key differences in workflows:**
```yaml
- uses: actions/setup-python@v4
  with:
    python-version: '3.11'
    cache: 'pip'

- run: pip install -r requirements.txt
- run: python -m pytest --cov
```

### Go Project

```yaml
- uses: actions/setup-go@v4
  with:
    go-version: '1.21'

- run: go test -v -cover ./...
- run: go build -o app
```

### .NET Project

```yaml
- uses: actions/setup-dotnet@v3
  with:
    dotnet-version: '7.0.x'

- run: dotnet build
- run: dotnet test --collect:"XPlat Code Coverage"
```

### Java/Maven Project

```yaml
- uses: actions/setup-java@v3
  with:
    java-version: '17'
    distribution: 'temurin'
    cache: maven

- run: mvn clean verify
```
