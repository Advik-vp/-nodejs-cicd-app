# MongoDB Installation Quick Reference

## 🚀 Quick Start (5 minutes)

### 1. NPM Dependencies

```bash
npm install
```

### 2. Start MongoDB

```bash
# Option A: Local Installation
mongod

# Option B: Docker (Recommended)
docker-compose up -d
```

### 3. Test Connection

```bash
node test-mongodb-connection.js
```

### 4. Run Application

```bash
npm run dev
```

---

## 📋 Installation by Platform

### Windows PowerShell

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\install-mongodb-windows.ps1
```

### macOS / Linux (Bash)

```bash
bash scripts/install-mongodb-unix.sh
```

---

## 🔍 Common Commands

### Verify Installation

```bash
mongosh --version
mongosh --eval "db.runCommand('ping')"
```

### Service Management

**Windows:**

```powershell
Get-Service mongod
Start-Service mongod
Stop-Service mongod
```

**macOS:**

```bash
brew services start mongodb-community
brew services stop mongodb-community
brew services list
```

**Linux:**

```bash
sudo systemctl start mongod
sudo systemctl stop mongod
sudo systemctl status mongod
```

### Docker Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs mongodb

# Stop services
docker-compose down

# Remove data
docker-compose down -v

# Access MongoDB in container
docker-compose exec mongodb mongosh
```

---

## 🧪 Testing

### Connection Test

```bash
node test-mongodb-connection.js
```

### Unit Tests

```bash
npm test -- mongodb.test.js
```

### Health Check Endpoint

```bash
curl http://localhost:3000/health
```

---

## 🔐 Security

### Set Environment Variables

```bash
# Copy example
cp .env.example .env

# Edit with your values
nano .env  # Linux/macOS
notepad .env  # Windows
```

### Required Credentials

```env
MONGO_URI=mongodb://admin:your_password@localhost:27017/app_db
MONGO_PASSWORD=your_secure_password
```

### Never Commit

```bash
# .gitignore should contain:
.env
.env.local
.env.*.local
```

---

## 🐳 Docker Quick Setup

```bash
# 1. Create .env file
echo "MONGO_PASSWORD=your_password" > .env

# 2. Start all services
docker-compose up -d

# 3. Verify
docker-compose ps

# 4. View UI
# MongoDB Express: http://localhost:8081
# App: http://localhost:3000
```

---

## 📊 Database Management

### Access mongosh

```bash
# Local connection
mongosh

# With authentication
mongosh "mongodb://admin:password@localhost:27017/admin"

# Docker connection
docker-compose exec mongodb mongosh
```

### Common mongosh Commands

```javascript
// Show all databases
show dbs

// Use database
use app_db

// Show all collections
show collections

// Count documents
db.users.countDocuments()

// Find documents
db.users.find()

// Create index
db.users.createIndex({ email: 1 })

// Drop collection
db.users.drop()
```

---

## ⚠️ Troubleshooting

### Connection Refused

```bash
# Check if MongoDB is running
mongosh --eval "db.runCommand('ping')"

# Start MongoDB
mongod  # Local
docker-compose up -d  # Docker
```

### Authentication Failed

```bash
# Verify connection string
echo $MONGO_URI

# Check credentials
mongosh "mongodb://admin:password@localhost:27017/admin"
```

### Port Already in Use

```bash
# Windows
netstat -ano | findstr :27017

# Linux/macOS
sudo lsof -i :27017

# Use different port or kill process
```

---

## 📚 API Examples

### GET /health

```bash
curl http://localhost:3000/health
```

### GET /api/users

```bash
curl http://localhost:3000/api/users
```

### POST /api/users

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'
```

### GET /api/users/:id

```bash
curl http://localhost:3000/api/users/[USER_ID]
```

### PUT /api/users/:id

```bash
curl -X PUT http://localhost:3000/api/users/[USER_ID] \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane"}'
```

### DELETE /api/users/:id

```bash
curl -X DELETE http://localhost:3000/api/users/[USER_ID]
```

---

## 🔗 Useful Resources

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Node.js MongoDB Driver](https://www.mongodb.com/docs/drivers/node/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [Full Setup Guide](./MONGODB_SETUP.md)
- [Installation Checklist](./MONGODB_DEPENDENCY_CHECKLIST.md)

---

## 📞 Need Help?

1. Check [MONGODB_SETUP.md](./MONGODB_SETUP.md) - Section 7: Troubleshooting
2. Run test script: `node test-mongodb-connection.js`
3. Check logs: `docker-compose logs mongodb`
4. Review [MONGODB_DEPENDENCY_CHECKLIST.md](./MONGODB_DEPENDENCY_CHECKLIST.md)
