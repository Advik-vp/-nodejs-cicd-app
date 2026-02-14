# MongoDB Dependencies Installation Guide

## 1. Context & Assumptions

### Target Environment

- **Primary OS**: Windows (PowerShell), Linux (Bash), macOS
- **Node.js**: v16+ (compatible with current project)
- **Package Managers**: npm, apt (Ubuntu/Debian), homebrew (macOS), Chocolatey (Windows)
- **Runtime**: Node.js with Express.js framework

### MongoDB Setup Type

- **Development**: Local MongoDB Community Edition
- **CI/CD**: Docker-based MongoDB (containerized)
- **Production**: Can be extended to MongoDB Atlas or managed services

### MongoDB Version

- **Target Version**: MongoDB 7.0 LTS (stable, widely supported)
- **Edition**: Community Edition (free, open-source)
- **Drivers**: Compatible with Node.js 16+

---

## 2. Complete Dependency List

### Runtime Dependencies (Production)

| Package    | Version   | Purpose                         | Required   |
| ---------- | --------- | ------------------------------- | ---------- |
| `mongodb`  | `^6.3.0`  | Official Node.js MongoDB driver | Yes        |
| `mongoose` | `^8.0.0`  | ODM (Object Document Mapper)    | Optional\* |
| `dotenv`   | `^16.3.1` | Environment variable management | Yes        |

\*Mongoose adds abstraction and schema validation; use if you prefer structured models.

### Development & Testing Dependencies

| Package                 | Version   | Purpose                     | Required    |
| ----------------------- | --------- | --------------------------- | ----------- |
| `mongodb-memory-server` | `^9.1.0`  | In-memory MongoDB for tests | Recommended |
| `jest`                  | `^29.7.0` | Already installed           | Yes         |
| `@types/node`           | `^20.0.0` | TypeScript types (optional) | Optional    |

### System/Database Tools

| Tool                     | Version | Purpose               | Installation                |
| ------------------------ | ------- | --------------------- | --------------------------- |
| MongoDB Community Server | 7.0+    | Database engine       | System package/Docker       |
| mongosh                  | 2.0+    | MongoDB shell client  | npm or system package       |
| MongoDB Compass          | Latest  | GUI client (optional) | Download or package manager |

### Container Approach (Recommended for CI/CD)

| Component     | Version     | Purpose                       |
| ------------- | ----------- | ----------------------------- |
| MongoDB Image | `mongo:7.0` | Docker official image         |
| mongo-express | `latest`    | Web UI for MongoDB (optional) |

---

## 3. Installation Steps

### A. NPM Package Installation (Node.js Driver)

#### Step 1: Add MongoDB Driver to package.json

```bash
# Install MongoDB driver
npm install mongodb@^6.3.0 dotenv@^16.3.1

# OR with Yarn
yarn add mongodb@^6.3.0 dotenv@^16.3.1

# OR with pnpm
pnpm add mongodb@^6.3.0 dotenv@^16.3.1
```

#### Step 2: Install Development Dependencies (Optional)

```bash
# For in-memory testing
npm install --save-dev mongodb-memory-server

# For TypeScript support (if using TypeScript)
npm install --save-dev @types/node @types/jest
```

### B. MongoDB Server Installation

#### Windows (PowerShell)

```powershell
# Option 1: Chocolatey Package Manager (Recommended)
choco install mongodb-community -y

# Option 2: Manual download from MongoDB website
# https://www.mongodb.com/try/download/community

# Option 3: Windows Subsystem for Linux (WSL)
# Use Linux installation steps in WSL terminal
```

#### macOS (Homebrew)

```bash
# Install MongoDB Community Edition
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB service
brew services start mongodb-community

# Verify installation
mongosh --version
```

#### Linux (Ubuntu/Debian)

```bash
# Add MongoDB repository
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update and install
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod  # Enable on boot

# Verify installation
mongosh --version
```

#### Linux (CentOS/RHEL)

```bash
# Add MongoDB repository
sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo << EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF

# Install
sudo yum install -y mongodb-org

# Start service
sudo systemctl start mongod
sudo systemctl enable mongod
```

### C. MongoDB Shell (mongosh) Installation

#### Windows

```powershell
choco install mongosh -y
# OR
npm install -g mongosh
```

#### macOS

```bash
brew install mongosh
```

#### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongosh
```

### D. Docker Installation (CI/CD & Containerized Environments)

#### Update docker-compose.yml

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    container_name: mongodb-dev
    restart: unless-stopped
    ports:
      - '27017:27017'
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-password123}
      MONGO_INITDB_DATABASE: app_db
    volumes:
      - mongodb_data:/data/db
      - mongodb_config:/data/configdb
    networks:
      - app-network
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 5

  mongo-express:
    image: mongo-express:latest
    container_name: mongodb-ui
    restart: unless-stopped
    ports:
      - '8081:8081'
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: ${MONGO_PASSWORD:-password123}
      ME_CONFIG_MONGODB_URL: mongodb://admin:${MONGO_PASSWORD:-password123}@mongodb:27017/
      ME_CONFIG_BASICAUTH: 'false'
    depends_on:
      - mongodb
    networks:
      - app-network

volumes:
  mongodb_data:
  mongodb_config:

networks:
  app-network:
    driver: bridge
```

#### Start MongoDB with Docker Compose

```bash
# Create .env file
echo "MONGO_PASSWORD=your_secure_password" > .env

# Start services
docker-compose up -d

# Verify
docker-compose ps
docker-compose logs mongodb

# Stop services
docker-compose down

# Clean up volumes (WARNING: deletes data)
docker-compose down -v
```

---

## 4. Validation & Verification

### A. Verify MongoDB Installation

#### Windows (PowerShell)

```powershell
# Check if MongoDB service is running
Get-Service MongoDB
Get-Service mongod

# Check version
mongosh --version
```

#### macOS/Linux (Bash)

```bash
# Check MongoDB service status
sudo systemctl status mongod
# or
brew services list | grep mongodb

# Check version
mongosh --version
mongo --version
```

### B. Connection Tests

#### Test with mongosh CLI

```bash
# Default connection (no authentication)
mongosh mongodb://localhost:27017

# With authentication
mongosh "mongodb://admin:password@localhost:27017/admin"

# Run a simple test
mongosh --eval "db.runCommand('ping')"
```

#### Test with Node.js Application

```javascript
// test-mongodb-connection.js
import { MongoClient } from 'mongodb';

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';

async function testConnection() {
  const client = new MongoClient(MONGO_URI);
  try {
    await client.connect();
    console.log('✅ MongoDB connected successfully');

    // Ping test
    const result = await client.db('admin').command({ ping: 1 });
    console.log('✅ Ping response:', result);

    // List databases
    const databases = await client.db('admin').admin().listDatabases();
    console.log('✅ Databases:', databases.databases.length);
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
  } finally {
    await client.close();
  }
}

testConnection();
```

Run test:

```bash
node test-mongodb-connection.js
```

### C. Performance & Health Checks

```javascript
// health-check.js
import { MongoClient } from 'mongodb';

async function healthCheck() {
  const client = new MongoClient('mongodb://localhost:27017');
  try {
    const startTime = Date.now();
    await client.connect();

    const result = await client.db('admin').command({ ping: 1 });
    const responseTime = Date.now() - startTime;

    console.log(`✅ MongoDB Health Check Passed (${responseTime}ms)`);
    console.log('Response:', result);
  } catch (error) {
    console.error('❌ Health Check Failed:', error.message);
  } finally {
    await client.close();
  }
}

healthCheck();
```

---

## 5. Security Best Practices

### A. Authentication & Authorization

#### Enable MongoDB Authentication

```bash
# Start MongoDB with authentication
mongod --auth

# Create admin user (mongosh)
mongosh
use admin
db.createUser({
  user: "admin",
  pwd: "secure_password_here",
  roles: [ { role: "root", db: "admin" } ]
})
```

#### Connect with Authentication

```javascript
const MONGO_URI = 'mongodb://admin:secure_password_here@localhost:27017/admin';
const client = new MongoClient(MONGO_URI);
```

### B. Environment Variables

Create `.env` file:

```env
MONGO_URI=mongodb://admin:secure_password@localhost:27017/app_db
MONGO_PASSWORD=secure_password
NODE_ENV=development
PORT=3000
```

Load in application:

```javascript
import dotenv from 'dotenv';
dotenv.config();

const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017';
```

### C. TLS/SSL Support

```javascript
// Secure connection with TLS
const MONGO_URI =
  'mongodb+srv://user:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority&tls=true';

const client = new MongoClient(MONGO_URI, {
  tlsCAFile: process.env.MONGO_CA_FILE,
  tlsCertificateKeyFile: process.env.MONGO_CERT_FILE,
});
```

### D. Network Security

- **Firewall**: Restrict port 27017 to trusted IPs only
- **Bind Address**: Change mongod bind address in config
- **Docker Networks**: Use isolated networks (don't expose on public ports)

### E. Credential Management

```javascript
// NEVER commit credentials
// ✅ DO: Use environment variables
const password = process.env.MONGO_PASSWORD;

// ✅ DO: Use .env files (add to .gitignore)
import dotenv from 'dotenv';
dotenv.config();

// ✅ DO: Use secrets management for CI/CD
// GitHub Secrets, AWS Secrets Manager, Vault, etc.
```

### F. Input Validation

```javascript
import { MongoClient, BSON } from 'mongodb';

// Validate ObjectId
function isValidObjectId(id) {
  return BSON.ObjectId.isValid(id);
}

// Sanitize queries
function sanitizeQuery(input) {
  if (typeof input !== 'string') return '';
  return input.replace(/[^\w\s]/gi, '');
}
```

---

## 6. Reproducible & Locked Dependencies

### A. npm Package Lock

```bash
# Generate lockfile
npm install
# Commits package-lock.json to git

# Install from lock (CI/CD)
npm ci
```

### B. Docker Image Pinning

```yaml
# Use specific version tags (not 'latest')
services:
  mongodb:
    image: mongo:7.0.3 # Specific version, not mongo:7.0
```

### C. Node.js Version Lock

```text
.nvmrc
16.19.0
```

Install specified version:

```bash
nvm install
nvm use
```

---

## 7. Troubleshooting Common Issues

### Issue 1: "Connection refused"

**Cause**: MongoDB service not running

**Solution**:

```bash
# Windows
Start-Service mongod

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

### Issue 2: "Authentication failed"

**Solution**:

```bash
# Verify credentials
mongosh "mongodb://admin:password@localhost:27017/admin"

# Reset password
mongosh
use admin
db.changeUserPassword("admin", "new_password")
```

### Issue 3: "Port 27017 already in use"

**Solution**:

```bash
# Windows
Get-NetTCPConnection -LocalPort 27017
Stop-Process -Id <PID>

# Linux
sudo lsof -i :27017
sudo kill -9 <PID>

# Use different port
mongod --port 27018
```

### Issue 4: Docker MongoDB connection timeout

**Solution**:

```bash
# Check container logs
docker-compose logs mongodb

# Verify network
docker network inspect app-network

# Use health check
docker-compose ps
```

### Issue 5: "Out of memory" errors

**Solution**:

- Increase system RAM or Docker memory limit
- Reduce data retention policies
- Enable compression

---

## 8. Next Steps

1. **Run installation scripts** (see Section 3)
2. **Execute verification tests** (see Section 4)
3. **Configure authentication** (see Section 5.A)
4. **Set up environment variables** (see Section 5.B)
5. **Integrate into application** (see example code below)

---

## 9. Quick Application Integration Example

```javascript
// src/mongodb-client.js
import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

let mongoClient;

export async function connectDatabase() {
  if (mongoClient?.topology?.isConnected()) {
    return mongoClient;
  }

  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
  mongoClient = new MongoClient(uri, {
    serverSelectionTimeoutMS: 5000,
  });

  try {
    await mongoClient.connect();
    console.log('✅ MongoDB connected');
    return mongoClient;
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    throw error;
  }
}

export async function closeDatabase() {
  if (mongoClient) {
    await mongoClient.close();
    console.log('✅ MongoDB disconnected');
  }
}

export function getDatabase() {
  return mongoClient?.db(process.env.MONGO_DB_NAME || 'app_db');
}
```

---

## 📚 Additional Resources

- [MongoDB Official Documentation](https://docs.mongodb.com/)
- [MongoDB Node.js Driver Docs](https://www.mongodb.com/docs/drivers/node/)
- [Mongoose Documentation](https://mongoosejs.com/)
- [MongoDB Atlas (Managed Service)](https://www.mongodb.com/cloud/atlas)
