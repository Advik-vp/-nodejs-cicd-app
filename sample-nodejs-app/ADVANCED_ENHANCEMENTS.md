# Optional Enhancements & Advanced Features

## 1. Security Enhancements

### SAST (Static Application Security Testing)

```yaml
# .github/workflows/security-scan.yml
name: Security Scanning

on: [push, pull_request]

jobs:
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/javascript
            p/owasp-top-ten

      - name: Run npm audit
        run: npm audit --production

      - name: OWASP Dependency-Check
        uses: jeremylong/DependencyCheck_Action@main
        with:
          project: 'Sample App'
          path: '.'
          format: 'SARIF'
```

### Container Image Scanning

```yaml
- name: Trivy Image Scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE }}:${{ github.sha }}
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload SARIF results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

### Secret Detection

```bash
# Install locally
npm install -g detect-secrets

# Scan for hardcoded secrets
detect-secrets scan --baseline .secrets.baseline

# In CI pipeline
- run: detect-secrets scan --baseline .secrets.baseline
```

---

## 2. Advanced Deployment Strategies

### Blue-Green Deployment

```yaml
deploy-production:
  steps:
    - name: Deploy blue version
      run: |
        # Deploy to blue environment
        ./scripts/deploy-blue.sh

    - name: Run smoke tests
      run: |
        # Test blue environment
        npm run smoke:tests

    - name: Switch traffic to green
      if: success()
      run: |
        # Switch load balancer
        ./scripts/switch-traffic.sh

    - name: Cleanup
      if: always()
      run: ./scripts/cleanup.sh
```

### Canary Deployment

```yaml
deploy-canary:
  runs-on: ubuntu-latest
  steps:
    - name: Deploy to 10% of traffic
      run: |
        kubectl set image deployment/app app=$IMAGE --record
        kubectl rollout status deployment/app
        # Monitor metrics for 5 minutes
        ./scripts/canary-monitor.sh

    - name: Promote to 100%
      if: success()
      run: |
        kubectl rollout undo deployment/app  # If needed
        # Full deployment continues
```

### Automated Rollback

```yaml
post-deployment:
  steps:
    - name: Health checks
      run: |
        for i in {1..10}; do
          if curl -f https://prod.example.com/health; then
            exit 0
          fi
          sleep 30
        done
        exit 1

    - name: Automatic rollback
      if: failure()
      run: |
        ./scripts/rollback-to-previous.sh
        ./scripts/notify-rollback.sh
```

---

## 3. Staging & Production Environments

### Environment Management

```yaml
# .github/workflows/deploy.yml
name: Deploy to Environment

on:
  push:
    branches: [develop, main]

env:
  STAGING_DOMAIN: staging.example.com
  PRODUCTION_DOMAIN: example.com

jobs:
  deploy:
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
      url: https://${{ github.ref == 'refs/heads/main' && env.PRODUCTION_DOMAIN || env.STAGING_DOMAIN }}

    steps:
      - name: Deploy to staging
        if: github.ref == 'refs/heads/develop'
        run: |
          export DEPLOY_ENV=staging
          ./scripts/deploy.sh

      - name: Manual approval required
        if: github.ref == 'refs/heads/main'
        uses: trstringer/manual-approval@v1
        with:
          secret: ${{ github.TOKEN }}
          approvers: 'devops-team'
          issue-title: 'Production Deployment Approval'

      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        run: |
          export DEPLOY_ENV=production
          ./scripts/deploy.sh
```

### Environment-Specific Configuration

Create separate config files:

```
config/
├── development.json
├── staging.json
└── production.json
```

```javascript
// Load appropriate config
const config = require(`./config/${process.env.NODE_ENV}.json`);
```

---

## 4. Performance Monitoring

### Lighthouse CI Integration

```yaml
lighthouse:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Run Lighthouse
      uses: treosh/lighthouse-ci-action@v9
      with:
        configPath: './lighthouserc.json'

    - name: Upload results
      uses: actions/upload-artifact@v3
      with:
        name: lighthouse-report
        path: ./lhci-results/
```

### SonarQube Analysis

```yaml
sonarqube:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - uses: actions/setup-node@v4

    - name: Install & test
      run: |
        npm ci
        npm run test -- --coverage

    - name: SonarQube Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Custom Metrics Collection

```bash
#!/bin/bash
# scripts/collect-metrics.sh

echo "Build metrics:"
echo "- Build time: $(date -d @START +%s)"
echo "- Bundle size: $(du -sh dist/ | cut -f1)"
echo "- Test coverage: $(grep -o '"pct":[0-9]*' coverage/coverage-summary.json | head -1)"

# Send to monitoring service
curl -X POST https://metrics.example.com/api/metrics \
  -H "Authorization: Bearer $METRICS_TOKEN" \
  -d "{
    \"build_time\": $BUILD_TIME,
    \"bundle_size\": $BUNDLE_SIZE,
    \"coverage\": $COVERAGE
  }"
```

---

## 5. Database Migration & Backup

### Automated Migrations

```yaml
- name: Run database migrations
  run: npm run migrate:up
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
  continue-on-error: false # Fail if migration fails

- name: Backup database
  if: success()
  run: |
    ./scripts/backup-database.sh
```

### Migration Rollback

```bash
#!/bin/bash
# scripts/emergency-rollback.sh

echo "EMERGENCY MIGRATION ROLLBACK"

# Restore from backup
pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME backup_$(date +%Y%m%d).dump

# Verify
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT version();"
```

---

## 6. Notification & Alerting

### Multi-Channel Notifications

```yaml
notify:
  if: always()
  runs-on: ubuntu-latest
  steps:
    - name: Slack notification
      uses: slackapi/slack-github-action@v1
      with:
        payload: |
          {"text": "Deployment: ${{ job.status }}"}
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

    - name: Email notification
      if: failure()
      uses: dawidd6/action-send-mail@v3
      with:
        server_address: smtp.gmail.com
        server_port: 465
        username: ${{ secrets.EMAIL_USERNAME }}
        password: ${{ secrets.EMAIL_PASSWORD }}
        subject: 'Pipeline Failed: ${{ github.run_id }}'
        body: 'Check: https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}'

    - name: PagerDuty alert
      if: failure()
      run: |
        curl -X POST https://events.pagerduty.com/v2/enqueue \
          -H "Content-Type: application/json" \
          -d "{
            \"routing_key\": \"${{ secrets.PAGERDUTY_KEY }}\",
            \"event_action\": \"trigger\",
            \"payload\": {
              \"summary\": \"Pipeline failure\",
              \"severity\": \"error\",
              \"source\": \"GitHub Actions\"
            }
          }"
```

---

## 7. Cost Optimization

### Reduce CI/CD Costs

```yaml
# Only run expensive tests on main/PRs
test-full:
  if: github.event_name == 'pull_request' || github.ref == 'refs/heads/main'

# Cache expensive operations
- uses: actions/cache@v3
  with:
    path: node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

# Matrix strategy for parallel runs
strategy:
  matrix:
    node-version: [18.x, 20.x]
  max-parallel: 2  # Limit concurrent jobs
```

---

## 8. Knowledge Base & Documentation

### Auto-Generate Documentation

```yaml
- name: Generate API docs
  run: npm run docs:generate

- name: Deploy docs
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./docs
```

### Architecture Decision Records (ADR)

Create `docs/adr/` directory with decision records:

```
docs/adr/
├── 001-ci-cd-platform.md
├── 002-container-registry.md
└── 003-deployment-strategy.md
```

### Runbook Templates

```bash
# docs/runbooks/troubleshoot-deployment.md

# When deployment fails:
1. Check logs: `kubectl logs -n prod app-pod`
2. Verify health: `curl https://prod.example.com/health`
3. Check database: `psql $DATABASE_URL -c "SELECT 1"`
4. Trigger rollback: `./scripts/rollback.sh`
5. Notify team: Post to #incidents Slack channel
```

---

## 9. Compliance & Audit

### Audit Trail

```yaml
- name: Log deployment
  run: |
    echo "${{ github.actor }} deployed ${{ github.ref }} at $(date)" \
      >> deployments.log

- name: Store audit log
  uses: actions/upload-artifact@v3
  with:
    name: audit-logs
    path: deployments.log
```

### SBOM (Software Bill of Materials)

```yaml
- name: Generate SBOM
  run: npm install -g @cyclonedx/npm && cyclonedx-npm -o sbom.xml

- name: Upload SBOM
  uses: actions/upload-artifact@v3
  with:
    name: sbom
    path: sbom.xml
```

---

## 10. Cost & Performance Monitoring

### Monthly Report

```bash
#!/bin/bash
# scripts/generate-ci-report.sh

echo "=== CI/CD Report for $(date +%B) ==="
echo "Total workflow runs: $(gh run list --repo $REPO | wc -l)"
echo "Failed runs: $(gh run list --repo $REPO --json conclusion | grep -c failure)"
echo "Average duration: $(gh run list --repo $REPO --json durationMinutes)"
echo "Total cost: $COST_ESTIMATE"
```

---

## Summary of Enhancements

| Enhancement            | Complexity | Benefits                    | Time    |
| ---------------------- | ---------- | --------------------------- | ------- |
| Security Scanning      | Medium     | Catch vulnerabilities early | +10 min |
| Blue-Green Deployment  | High       | Zero-downtime deployments   | +30 min |
| Performance Monitoring | Medium     | Track real-world metrics    | +15 min |
| Database Migrations    | Medium     | Automated schema changes    | +20 min |
| Multi-channel Alerts   | Low        | Never miss failures         | +5 min  |
| Cost Optimization      | Low        | Reduce CI/CD costs          | +5 min  |

Start with security scanning, add deployment strategies, then monitoring as your needs grow.
