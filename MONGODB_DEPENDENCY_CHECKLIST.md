# MongoDB Dependency Installation Checklist

A quick reference checklist for verifying MongoDB installation completion.

---

## 📋 Pre-Installation Requirements

- [ ] Node.js v16+ installed
- [ ] npm or yarn package manager available
- [ ] Administrator/sudo access (for system-level installs)
- [ ] 2GB+ disk space available
- [ ] Port 27017 not in use (default MongoDB port)
- [ ] Internet connection for downloads

---

## 🛠️ NPM Dependency Installation

### Core MongoDB Driver

- [ ] `mongodb@^6.3.0` installed
  ```bash
  npm list mongodb
  ```

- [ ] `dotenv@^16.3.1` installed
  ```bash
  npm list dotenv
  ```

### Optional: ODM (Object Document Mapper)

- [ ] `mongoose@^8.0.0` installed (if using mongoose)
  ```bash
  npm list mongoose
  ```

### Development Dependencies

- [ ] `mongodb-memory-server@^9.1.0` installed
  ```bash
  npm list --save-dev mongodb-memory-server
  ```

- [ ] `@types/node` installed
  ```bash
  npm list --save-dev @types/node
  ```

- [ ] `@types/jest` installed
  ```bash
  npm list --save-dev @types/jest
  ```

---

## 🗄️ MongoDB Server Installation

### Windows

- [ ] MongoDB Community Edition installed
  ```powershell
  Get-Command mongosh
  mongosh --version
  ```

- [ ] MongoDB service installed and running
  ```powershell
  Get-Service MongoDB
  Get-Service mongod
  ```

- [ ] Data directory exists at `C:\Data\MongoDB`
  ```powershell
  Test-Path "C:\Data\MongoDB"
  ```

- [ ] mongosh CLI tool available
  ```powershell
  mongosh --version
  ```

### macOS

- [ ] Homebrew installed
  ```bash
  brew --version
  ```

- [ ] MongoDB Community Edition installed
  ```bash
  brew list | grep mongodb
  ```

- [ ] MongoDB service running
  ```bash
  brew services list | grep mongodb
  ```

- [ ] mongosh CLI tool available
  ```bash
  mongosh --version
  ```

### Linux (Ubuntu/Debian)

- [ ] MongoDB repository added
  ```bash
  cat /etc/apt/sources.list.d/mongodb-org-7.0.list
  ```

- [ ] MongoDB Community Edition installed
  ```bash
  dpkg -l | grep mongodb-org
  ```

- [ ] MongoDB service running
  ```bash
  sudo systemctl status mongod
  ```

- [ ] mongosh CLI tool available
  ```bash
  mongosh --version
  ```

### Linux (CentOS/RHEL)

- [ ] MongoDB repository added
  ```bash
  cat /etc/yum.repos.d/mongodb-org-7.0.repo
  ```

- [ ] MongoDB Community Edition installed
  ```bash
  yum list installed | grep mongodb
  ```

- [ ] MongoDB service running
  ```bash
  sudo systemctl status mongod
  ```

---

## 🔗 Connectivity Verification

### CLI Connection Test

- [ ] Connect via mongosh without authentication
  ```bash
  mongosh mongodb://localhost:27017
  > db.runCommand('ping')
  ```

- [ ] Connection returns successful ping response
  ```
  { ok: 1 }
  ```

- [ ] List databases available
  ```bash
  mongosh --eval "db.adminCommand('listDatabases')"
  ```

### Node.js Application Connection

- [ ] Create test file: `test-mongodb-connection.js`
  ```bash
  [ -f test-mongodb-connection.js ]
  ```

- [ ] Run connection test successfully
  ```bash
  node test-mongodb-connection.js
  ```

- [ ] Output shows "✅ MongoDB connected successfully"

---

## 🔐 Security Configuration

### Authentication Setup

- [ ] Admin user created in MongoDB
  ```bash
  mongosh
  > use admin
  > db.getUser("admin")
  ```

- [ ] Authentication enabled in MongoDB config
  ```bash
  # Check mongod configuration
  grep "security:" /etc/mongod.conf
  ```

- [ ] Connection string includes credentials
  ```
  MONGO_URI=mongodb://admin:password@localhost:27017/admin
  ```

### Environment Variables

- [ ] `.env` file created in project root
  ```bash
  [ -f .env ]
  ```

- [ ] `.env` file added to `.gitignore`
  ```bash
  grep "^\.env$" .gitignore
  ```

- [ ] `.env` contains all required variables
  ```env
  MONGO_URI=...
  MONGO_DB_NAME=...
  MONGO_PASSWORD=...
  NODE_ENV=...
  PORT=...
  ```

- [ ] Credentials not committed to git
  ```bash
  git log --all --oneline --grep=".env"
  # Should return no results
  ```

---

## 🐳 Docker Setup (Optional)

### Docker Installation

- [ ] Docker Desktop installed
  ```bash
  docker --version
  ```

- [ ] Docker daemon running
  ```bash
  docker ps
  ```

### Docker Compose Configuration

- [ ] `docker-compose.yml` file exists
  ```bash
  [ -f docker-compose.yml ]
  ```

- [ ] MongoDB service defined in docker-compose.yml
  ```bash
  grep "image: mongo:" docker-compose.yml
  ```

- [ ] MongoDB volume defined
  ```bash
  grep "mongodb_data:" docker-compose.yml
  ```

### Docker Container Management

- [ ] MongoDB container runs successfully
  ```bash
  docker-compose up -d
  docker-compose ps
  ```

- [ ] Container health check passes
  ```bash
  docker-compose ps | grep healthy
  ```

- [ ] Container logs show no errors
  ```bash
  docker-compose logs mongodb
  ```

---

## 📦 Lock Files & Reproducible Builds

### Dependencies Lock

- [ ] `package-lock.json` generated
  ```bash
  [ -f package-lock.json ]
  ```

- [ ] `package-lock.json` committed to git
  ```bash
  git ls-files | grep package-lock.json
  ```

- [ ] `.nvmrc` file specifies Node.js version (optional)
  ```bash
  [ -f .nvmrc ]
  ```

### Docker Image Versioning

- [ ] MongoDB image uses specific version tag (not 'latest')
  ```bash
  grep "image: mongo:" docker-compose.yml | grep -v "mongo:latest"
  ```

---

## ✅ Application Integration

### MongoDB Client Module

- [ ] Database connection module created
  ```bash
  [ -f src/mongodb-client.js ]
  ```

- [ ] Connection pooling configured
  ```bash
  grep "MongoClient" src/mongodb-client.js
  ```

### Application Setup

- [ ] MongoDB connection initialized on app startup
  ```bash
  grep -r "connectDatabase" src/
  ```

- [ ] Environment variables loaded
  ```bash
  grep "dotenv.config" src/
  ```

- [ ] Error handling for connection failures
  ```bash
  grep -r "catch.*error" src/
  ```

---

## 🧪 Testing & Validation

### Unit Tests

- [ ] Test file exists: `tests/mongodb.test.js`
  ```bash
  [ -f tests/mongodb.test.js ]
  ```

- [ ] Tests pass locally
  ```bash
  npm test -- mongodb.test.js
  ```

- [ ] In-memory MongoDB used for tests (optional)
  ```bash
  grep "mongodb-memory-server" tests/mongodb.test.js
  ```

### Health Checks

- [ ] Health check endpoint defined
  ```bash
  grep -r "/health" src/
  ```

- [ ] Health check includes database connectivity
  ```bash
  grep -A 5 "GET /health" src/
  ```

- [ ] Health endpoint returns 200 on success
  ```bash
  curl http://localhost:3000/health | grep ok
  ```

---

## 📊 Performance & Monitoring

### Connection Metrics

- [ ] Connection timeout configured
  ```bash
  grep "serverSelectionTimeoutMS" src/
  ```

- [ ] Connection pooling limits set
  ```bash
  grep -r "maxPoolSize\|minPoolSize" src/
  ```

### Logging

- [ ] MongoDB operations logged
  ```bash
  grep -r "console.log\|logger" src/
  ```

- [ ] Query performance monitored (optional)
  ```bash
  grep -r "performance\|duration" src/
  ```

---

## 🔧 Troubleshooting Checks

### Connection Issues

- [ ] MongoDB service is running
  ```bash
  mongosh --eval "db.runCommand('ping')"
  ```

- [ ] Correct port 27017 (or custom port) in connection string
  ```bash
  echo $MONGO_URI | grep 27017
  ```

- [ ] No firewall blocking port 27017
  ```bash
  # Windows: netstat -an | find ":27017"
  # Linux: sudo netstat -an | grep :27017
  ```

### Authentication Issues

- [ ] Credentials correct in connection string
  ```bash
  mongosh "mongodb://admin:password@localhost:27017/admin"
  ```

- [ ] Database user has required permissions
  ```bash
  mongosh --eval "use admin; db.getUser('admin')"
  ```

### Performance Issues

- [ ] MongoDB memory usage acceptable
  ```bash
  # Check process memory
  # Windows: Get-Process mongod | Select-Object WorkingSet
  # Linux: ps aux | grep mongod
  ```

- [ ] Indexes created for frequently queried fields (when applicable)
  ```bash
  mongosh --eval "db.collection.getIndexes()"
  ```

---

## 📋 CI/CD Integration Checklist

### GitHub Actions / CI Pipeline

- [ ] MongoDB service container defined in workflow
  ```bash
  grep -r "image: mongo:" .github/
  ```

- [ ] Connection string configured for CI environment
  ```bash
  grep -r "MONGO_URI" .github/
  ```

- [ ] Tests run against MongoDB in CI
  ```bash
  grep -r "npm test" .github/
  ```

- [ ] Database migrations/seeding included in pipeline
  ```bash
  grep -r "migrate\|seed" .github/
  ```

### Docker Build Pipeline

- [ ] Dockerfile includes MongoDB client installation
  ```bash
  grep -i "mongodb\|mongosh" Dockerfile
  ```

- [ ] Node.js dependencies installed in Docker
  ```bash
  grep "npm install" Dockerfile
  ```

- [ ] Health check defined in Dockerfile
  ```bash
  grep "HEALTHCHECK" Dockerfile
  ```

---

## 📚 Documentation

### Project Documentation

- [ ] MongoDB setup guide created
  ```bash
  [ -f MONGODB_SETUP.md ]
  ```

- [ ] Installation scripts provided
  ```bash
  [ -f scripts/install-mongodb-*.sh ]
  [ -f scripts/install-mongodb-*.ps1 ]
  ```

- [ ] README includes MongoDB setup section
  ```bash
  grep -i "mongodb" README.md
  ```

- [ ] Troubleshooting guide available
  ```bash
  grep -i "troubleshoot" MONGODB_SETUP.md
  ```

---

## ✨ Final Verification

### Complete System Test

- [ ] All npm packages installed
  ```bash
  npm list | grep mongodb
  ```

- [ ] MongoDB service running
  ```bash
  mongosh --eval "db.runCommand('ping')"
  ```

- [ ] Node.js application connects successfully
  ```bash
  node test-mongodb-connection.js
  ```

- [ ] Tests pass
  ```bash
  npm test
  ```

- [ ] Application starts without errors
  ```bash
  npm run dev
  ```

---

## 🎯 Sign-Off

- [ ] Installation completed successfully
- [ ] All verification tests passed
- [ ] Documentation reviewed and understood
- [ ] Team/stakeholders notified of completion
- [ ] Ready for development/deployment

**Date Completed**: _______________

**Completed By**: _______________

**Notes/Issues**: 
```
[List any issues or special configurations here]
```

---

## 📞 Support Resources

- **MongoDB Docs**: https://docs.mongodb.com/
- **Node.js Driver**: https://www.mongodb.com/docs/drivers/node/
- **Troubleshooting**: See MONGODB_SETUP.md - Section 7
- **Installation Scripts**: See `scripts/` directory

