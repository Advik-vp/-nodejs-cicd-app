# NodeJS CI/CD App & Cloud Vault

This is a production-ready Node.js app with a full CI/CD pipeline, now featuring **Cloud Vault** - a secure and creative local file storage system.

## 🚀 Quick Start

1.  **Install Dependencies**:
    ```bash
    npm install
    cd frontend && npm install && cd ..
    ```

2.  **Run Locally (Frontend + Backend)**:
    ```bash
    npm run dev
    ```
    -   Backend runs on `http://localhost:3000`
    -   Frontend runs on `http://localhost:5173`

3.  **Build for Production**:
    ```bash
    npm run build
    npm start
    ```

## features

-   **Cloud Vault**: Secure file upload with drag-and-drop interface.
-   **Creative UI**: Modern glassmorphism design using React & Vite.
-   **CI/CD**: Automated pipeline for testing and deployment.

## 🚀 Quick Start (5 minutes)

```bash
# 1. Clone & setup
bash scripts/quickstart.sh

# 2. Run locally
npm run dev

# 3. Commit & push to trigger pipeline
git push origin feature/my-feature
```

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for daily commands.

---

## 📋 Features

✅ **Automated Quality Checks**

- ESLint + Prettier code style enforcement
- Jest unit tests with 70% coverage requirement
- Pre-commit hooks with Husky

✅ **Secure & Scalable**

- Docker containerization with multi-stage builds
- GitHub Actions CI/CD with parallel jobs
- Security scanning (Trivy, npm audit)
- SonarCloud code quality analysis

✅ **Deployment Ready**

- Staging & production environments
- Container image publishing to GHCR
- Zero-downtime deployment strategies
- Health checks & automatic rollback

✅ **Developer Friendly**

- VS Code integration with recommended extensions
- Local pipeline testing with ACT
- Comprehensive documentation
- Clear error messages & troubleshooting

---

## 🏗️ Architecture

```
Push to GitHub
       ↓
GitHub Actions Triggers
       ├── Quality (lint, format)  ← Run in parallel
       ├── Test (unit tests)       ← Run in parallel
       ├── Build (Docker, security scan)
       └── Integration tests
       ↓
If develop: Deploy to Staging ← Automatic
If main: Request manual approval → Deploy to Production
       ↓
Health checks + Rollback on failure
```

---

## 📁 Project Structure

```
.
├── .github/workflows/           # GitHub Actions workflows
│   ├── ci-cd.yml               # Main pipeline (build → test → deploy)
│   ├── docker-publish.yml       # Container image publishing
│   └── code-analysis.yml        # Security & code quality
├── src/                         # Application source
│   └── index.js                 # Express app entry point
├── tests/                       # Jest test suite
│   └── index.test.js
├── scripts/                     # Automation scripts
│   ├── quickstart.sh            # 5-minute setup
│   ├── local-ci.sh              # Run CI locally
│   ├── install-tools.sh         # Install dev tools
│   └── setup.sh                 # Initial configuration
├── Dockerfile                   # Multi-stage container build
├── docker-compose.yml           # Local dev environment
├── package.json                 # Dependencies & scripts
├── jest.config.js               # Test configuration
├── .eslintrc.json               # Linting rules
├── .prettierrc.json             # Code formatting
└── QUICK_REFERENCE.md           # Daily commands cheat sheet
```

---

## 📚 Documentation

| Document                                                               | Purpose                                         |
| ---------------------------------------------------------------------- | ----------------------------------------------- |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md)                               | Daily commands, quick setup, common issues      |
| [SETUP_GUIDE.md](SETUP_GUIDE.md)                                       | Detailed installation, prerequisites, workflows |
| [VALIDATION_AND_TROUBLESHOOTING.md](VALIDATION_AND_TROUBLESHOOTING.md) | Debugging, issue solutions, best practices      |
| [ADVANCED_ENHANCEMENTS.md](ADVANCED_ENHANCEMENTS.md)                   | Security, monitoring, advanced deployments      |
| [CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)               | Environment variables, workflow customization   |

---

## 🔧 Development

### Prerequisites

- Node.js 20+ ([download](https://nodejs.org/))
- Docker ([download](https://docker.com))
- Git ([download](https://git-scm.com))

### Local Development

```bash
# Install dependencies
npm install

# Setup Git hooks
npx husky install

# Create environment file
cp .env.example .env

# Start development server (auto-reload)
npm run dev

# Watch mode for tests
npm run test:watch
```

### Code Quality

```bash
# Lint code
npm run lint                   # Check for issues
npm run lint:fix              # Auto-fix issues

# Format code
npm run format                # Auto-format with Prettier
npm run format:check          # Check without modifying

# Run tests
npm run test                  # Full test suite
npm run test:watch            # Watch mode
npm run test -- --coverage    # With coverage report
```

### Run Complete Pipeline Locally

```bash
# Simulate GitHub Actions pipeline
bash scripts/local-ci.sh

# Or run individually
npm run lint
npm run test
npm run docker:build
```

---

## 🐳 Docker

### Build & Run

```bash
# Build image
npm run docker:build

# Run container
npm run docker:run

# Test application
curl http://localhost:3000/health
curl http://localhost:3000/api/users
```

### Docker Compose (with Database)

```bash
# Start all services (app + PostgreSQL)
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f app
```

---

## 🚢 Deployment

### GitHub Actions Workflows

| Workflow               | Trigger              | Actions                          |
| ---------------------- | -------------------- | -------------------------------- |
| **ci-cd.yml**          | Push to main/develop | Lint → Test → Build → Deploy     |
| **docker-publish.yml** | Push to main/tags    | Build & publish container image  |
| **code-analysis.yml**  | Weekly + PR          | SonarCloud & dependency scanning |

### Environment Variables

Create `.env` file from template:

```bash
cp .env.example .env
# Edit with your configuration
```

Add GitHub Secrets for production:

```
Settings → Secrets and variables → Actions → New repository secret
```

Required secrets:

- `DATABASE_URL` - Production database connection
- `API_SECRET` - API authentication key
- `SLACK_WEBHOOK` - Slack notifications (optional)

### Deployment Branches

- **develop** → Staging (automatic)
- **main** → Production (requires manual approval)

---

## 🧪 Quality Gates

### Test Coverage Requirements

```javascript
Branches: 70 % minimum;
Functions: 70 % minimum;
Lines: 70 % minimum;
Statements: 70 % minimum;
```

### Linting Standards

- ESLint with Airbnb config
- Prettier code formatting
- Pre-commit hooks prevent violations

### Security Checks

- npm audit (moderate+ severity fails build)
- Trivy container scanning
- SonarCloud code analysis
- GitHub dependency scanning

---

## 🔍 Monitoring & Debugging

### View Pipeline Status

1. Go to **Actions** tab in GitHub
2. Click workflow run to see details
3. Click job to see step logs

### Local Testing with ACT

```bash
# Install ACT (local GitHub Actions runner)
brew install act  # macOS
choco install act # Windows

# Run workflow locally
act push -b              # Simulate push event
act -j quality           # Run specific job
act -v                   # Verbose output
```

### Common Commands

```bash
# Check Node & npm versions
node --version
npm --version

# See all available scripts
npm run

# Check Docker status
docker ps
docker logs <container-id>

# Test API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/users
```

---

## 📖 Troubleshooting

See [VALIDATION_AND_TROUBLESHOOTING.md](VALIDATION_AND_TROUBLESHOOTING.md) for:

- Common errors and solutions
- Debug workflow locally
- Performance optimization
- Security best practices
- Rollback procedures

Quick issues:
| Issue | Solution |
|-------|----------|
| Tests fail locally | `npm run test -- --forceExit` |
| Linting errors | `npm run lint:fix` |
| Docker build fails | `docker system prune -a && npm run docker:build` |
| Port 3000 in use | `lsof -i :3000 && kill -9 <PID>` |
| Workflow not triggering | Check `.github/workflows/` file path |

---

## 🎯 Next Steps

1. **Setup** (First time)

   ```bash
   bash scripts/quickstart.sh
   ```

2. **Configure Secrets** (GitHub)
   - Add DATABASE_URL, API_SECRET, etc.

3. **Create First Branch & PR**

   ```bash
   git checkout -b feature/my-feature
   # Make changes
   git push origin feature/my-feature
   ```

4. **Monitor Pipeline**
   - Go to Actions tab
   - Watch automated checks run
   - Request code review
   - Merge when approved

5. **Deploy to Production**
   - Merge feature to `develop` (automatic staging deploy)
   - Merge to `main` (automatic production deploy with approval)

---

## 📚 Advanced Features

See [ADVANCED_ENHANCEMENTS.md](ADVANCED_ENHANCEMENTS.md) for:

- 🔒 Security scanning (SAST, DAST, container scanning)
- 🚀 Deployment strategies (blue-green, canary)
- 📊 Performance monitoring (Lighthouse, metrics)
- 🗄️ Database migrations & backups
- 📢 Multi-channel notifications
- 💰 Cost optimization
- 📋 Compliance & audit trails

---

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and test: `npm run build`
3. Commit: `git commit -m "feat: description"`
4. Push: `git push origin feature/my-feature`
5. Create Pull Request on GitHub
6. Wait for automated checks to pass
7. Request code review
8. Merge when approved

---

## 📝 License

MIT

---

## 🆘 Support

- **Documentation**: See links above
- **Issues**: GitHub Issues tab
- **Questions**: Create Discussion
- **Security**: Report privately to maintainers

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `npm run dev` starts the application
- [ ] `npm run test` passes all tests
- [ ] `npm run lint` has no errors
- [ ] `npm run docker:build` builds successfully
- [ ] Webhook to GitHub configured
- [ ] GitHub Actions workflows visible in Actions tab
- [ ] Secrets added (DATABASE_URL, API_SECRET, etc.)
- [ ] First commit triggers CI/CD pipeline

---

**Ready to deploy?** Start with [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for daily commands and workflows!
