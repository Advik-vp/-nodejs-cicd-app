# MongoDB GitHub CI/CD - Quick Setup Guide

**Time Required**: 10 minutes  
**Difficulty**: Easy  
**Status**: ✅ Ready to Deploy

---

## 🎯 What You Get

✅ Automatic MongoDB testing on every commit  
✅ Performance monitoring in CI/CD  
✅ Security scanning for credentials  
✅ Docker Compose integration testing  
✅ Daily scheduled verification runs

---

## ⚡ 5-Minute Setup

### Step 1: Add GitHub Secret (2 minutes)

**Option A: Using GitHub Web UI**

1. Go to your GitHub repository
2. Click **Settings** (top right)
3. Select **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Name: `MONGO_PASSWORD`
6. Value: `your_secure_password_here`
7. Click **Add secret**

**Option B: Using GitHub CLI**

```bash
gh secret set MONGO_PASSWORD --body "your_secure_password"
```

**Option C: Using Setup Script**

Windows:

```powershell
.\scripts\setup-github-mongodb-cicd.ps1
```

macOS/Linux:

```bash
bash scripts/setup-github-mongodb-cicd.sh
```

### Step 2: Push Code (2 minutes)

```bash
git add .
git commit -m "Add MongoDB CI/CD integration"
git push origin main
```

### Step 3: Monitor (1 minute)

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Watch workflows run ✅

---

## 📊 What's Running

### Main CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Runs on**: Every commit/PR to main/develop

**Jobs**:

- ✅ Code Quality (ESLint, Prettier)
- ✅ Unit Tests **with MongoDB** ← NEW!
- ✅ Build & Security Scan

**Time**: ~5-8 minutes

### MongoDB Integration Tests (`.github/workflows/mongodb-integration.yml`)

**Runs on**: Every commit/PR + Daily schedule

**Jobs**:

1. ✅ Connection Tests - Verify MongoDB is working
2. ✅ Performance Tests - Benchmark query speed
3. ✅ Backup Tests - Verify backup capabilities
4. ✅ Docker Compose - Full stack integration
5. ✅ Security Scan - Check for hardcoded secrets

**Time**: ~10-15 minutes

---

## 🔍 View Results

### On GitHub Web UI

1. Go to **Actions** tab
2. Select workflow run
3. Click on job to see details

### Using GitHub CLI

```bash
# List all runs
gh run list

# View specific run
gh run view <run-id>

# View logs
gh run view <run-id> --log

# View MongoDB Integration runs
gh run list --workflow=mongodb-integration.yml
```

---

## 🟢 Success Indicators

### When Everything Works

```
✅ Code Quality Checks     → PASS
✅ Unit Tests              → PASS (with MongoDB)
✅ Build & Security        → PASS
✅ MongoDB Integration     → PASS
✅ Performance Tests       → PASS
✅ Docker Compose Tests    → PASS
✅ Security Scan          → PASS
```

### If Tests Fail

Check the error logs:

1. Click on failed job
2. Expand the step that failed
3. Read error message
4. See troubleshooting section below

---

## 🆘 Troubleshooting

### "MongoDB connection refused"

**Fix**: MongoDB service takes time to start

- Workflows include 30-second retry
- Check logs for: `✅ MongoDB is ready!`

### "MONGO_PASSWORD secret not found"

**Fix**: You need to add the secret first

1. Go to Repository → Settings → Secrets
2. Click **New repository secret**
3. Add `MONGO_PASSWORD`
4. Re-run workflow

### "Tests timeout after 15 minutes"

**Fix**: Check MongoDB logs

```bash
gh run view <run-id> --log | grep -i mongodb
```

### "Docker Compose command not found"

**Fix**: This shouldn't happen on GitHub CI

- GitHub Actions uses `ubuntu-latest` which includes Docker
- Run locally to test

---

## 📋 Files Updated/Created

| File                                        | Status  | Purpose                 |
| ------------------------------------------- | ------- | ----------------------- |
| `.github/workflows/ci-cd.yml`               | UPDATED | Added MongoDB service   |
| `.github/workflows/mongodb-integration.yml` | NEW     | Dedicated MongoDB tests |
| `.env.example`                              | Exists  | Environment template    |
| `test-mongodb-connection.js`                | Exists  | Connection validator    |
| `tests/mongodb.test.js`                     | Exists  | Unit tests              |
| `src/mongodb-client.js`                     | Exists  | Connection manager      |
| `docker-compose.yml`                        | Updated | Full stack config       |
| `scripts/setup-github-mongodb-cicd.sh`      | NEW     | Linux setup script      |
| `scripts/setup-github-mongodb-cicd.ps1`     | NEW     | Windows setup script    |
| `GITHUB_MONGODB_CI_CD_GUIDE.md`             | NEW     | Detailed guide          |

---

## 🔒 Security Notes

✅ **Already Secure**:

- No hardcoded credentials
- Uses GitHub Secrets
- Environment variables only
- `.env` in .gitignore

⚠️ **You Must Do**:

1. Use strong password for `MONGO_PASSWORD`
2. Never commit `.env` file
3. Rotate credentials regularly
4. Limit who can see secrets (GitHub permissions)

---

## 📊 Environment Variables

In workflows:

```yaml
MONGO_URI: mongodb://admin:${{ secrets.MONGO_PASSWORD }}@localhost:27017/test_db
MONGO_DB_NAME: test_db
NODE_ENV: test
PORT: 3000
```

In your code:

```javascript
const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
```

---

## 🚀 Advanced Usage

### Trigger Workflow Manually

```bash
# Trigger specific workflow
gh workflow run ci-cd.yml

# Trigger MongoDB tests
gh workflow run mongodb-integration.yml

# Run with branch
gh workflow run ci-cd.yml --ref main
```

### View Workflow Details

```bash
# List all workflows
gh workflow list

# View workflow file
gh workflow view ci-cd.yml

# Get workflow info
gh workflow view mongodb-integration.yml --yaml
```

### Debug Mode

Add to workflow step:

```yaml
- name: Enable debug
  run: |
    echo "::debug::Debug message here"
    env | sort
    mongosh --version
```

---

## 🎯 Next Steps

1. **Add Secret**:

   ```
   GitHub Settings → Secrets → Add MONGO_PASSWORD
   ```

2. **Push Code**:

   ```bash
   git push origin main
   ```

3. **Monitor**:

   ```bash
   gh run list
   ```

4. **Verify Success**:
   - All workflows show ✅ green
   - MongoDB connection established
   - Tests passed

5. **Read Full Guide** (optional):
   - See `GITHUB_MONGODB_CI_CD_GUIDE.md`

---

## 📞 Quick Reference

| Command                        | What It Does           |
| ------------------------------ | ---------------------- |
| `gh secret set MONGO_PASSWORD` | Add GitHub secret      |
| `gh workflow run ci-cd.yml`    | Trigger CI/CD          |
| `gh run list`                  | View all workflow runs |
| `gh run view <id>`             | View specific run      |
| `git push origin main`         | Trigger workflows      |

---

## ✅ Checklist

- [ ] Added `MONGO_PASSWORD` to GitHub Secrets
- [ ] Pushed code to GitHub
- [ ] Actions tab shows running workflows
- [ ] All workflows show ✅ green
- [ ] MongoDB connection verified in logs
- [ ] Tests passed with MongoDB
- [ ] Docker Compose integration working
- [ ] Security scan passed
- [ ] Ready for production

---

## 🎉 You're Done!

Your MongoDB is now connected to GitHub CI/CD!

```
✅ Automated Testing
✅ Performance Monitoring
✅ Security Scanning
✅ Docker Integration
✅ Production Ready
```

**Status**: Live and Running 🚀

---

## 📖 Learn More

- **Full Guide**: `GITHUB_MONGODB_CI_CD_GUIDE.md`
- **GitHub Actions**: https://docs.github.com/en/actions
- **MongoDB Docs**: https://docs.mongodb.com/
- **GitHub CLI**: https://cli.github.com/

---

**Last Updated**: January 19, 2026  
**Version**: 1.0  
**Status**: ✅ Production Ready
