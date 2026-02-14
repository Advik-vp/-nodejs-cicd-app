# MongoDB Dependencies Installation Script for Windows (PowerShell)
# =================================================================
# This script installs MongoDB and all required dependencies on Windows

param(
    [string]$MongoVersion = "7.0",
    [string]$InstallPath = "C:\Program Files\MongoDB",
    [string]$DataPath = "C:\Data\MongoDB",
    [switch]$Docker = $false,
    [switch]$SkipMongosh = $false,
    [switch]$SkipCompass = $false,
    [switch]$Admin = $false
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }
function Write-Warning-Custom { Write-Host $args -ForegroundColor Yellow }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Error-Custom "❌ This script requires Administrator privileges."
    Write-Info "Please run PowerShell as Administrator or use -Admin flag with credentials."
    exit 1
}

Write-Info "================================"
Write-Info "MongoDB Installation Script"
Write-Info "================================"
Write-Info ""

# 1. NPM Package Installation
Write-Info "Step 1: Installing NPM packages..."
try {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Info "Installing mongodb driver..."
        npm install mongodb@^6.3.0 dotenv@^16.3.1
        Write-Success "✅ NPM packages installed successfully"
    } else {
        Write-Error-Custom "❌ npm not found. Please install Node.js first."
        exit 1
    }
} catch {
    Write-Error-Custom "❌ Failed to install NPM packages: $_"
    exit 1
}

# 2. Check if using Docker
if ($Docker) {
    Write-Info ""
    Write-Info "Step 2: Docker mode enabled"
    Write-Info "Skipping MongoDB server installation (use Docker instead)"
    
    # Check Docker installation
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "❌ Docker not found. Please install Docker Desktop."
        exit 1
    }
    
    Write-Success "✅ Docker available for MongoDB deployment"
    Write-Info ""
    Write-Info "To start MongoDB with Docker Compose:"
    Write-Info "  docker-compose up -d"
    exit 0
}

# 3. Chocolatey Installation
Write-Info ""
Write-Info "Step 2: Installing MongoDB Community Edition via Chocolatey..."

# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Warning-Custom "⚠️  Chocolatey not found. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install MongoDB Community Edition
try {
    Write-Info "Installing MongoDB Community Edition $MongoVersion..."
    choco install mongodb-community -y --version=$MongoVersion
    Write-Success "✅ MongoDB Community Edition installed"
} catch {
    Write-Warning-Custom "⚠️  Chocolatey installation encountered issues. Trying alternative method..."
    # Alternative: Download from MongoDB
    Write-Info "Please download from: https://www.mongodb.com/try/download/community"
    exit 1
}

# 4. Create MongoDB Data Directory
Write-Info ""
Write-Info "Step 3: Creating MongoDB data directory..."
if (-not (Test-Path $DataPath)) {
    try {
        New-Item -ItemType Directory -Path $DataPath -Force | Out-Null
        Write-Success "✅ Data directory created: $DataPath"
    } catch {
        Write-Error-Custom "❌ Failed to create data directory: $_"
        exit 1
    }
}

# 5. Install mongosh (MongoDB Shell)
if (-not $SkipMongosh) {
    Write-Info ""
    Write-Info "Step 4: Installing mongosh (MongoDB Shell)..."
    try {
        choco install mongosh -y
        Write-Success "✅ mongosh installed successfully"
    } catch {
        Write-Warning-Custom "⚠️  Failed to install mongosh via Chocolatey. Trying npm..."
        try {
            npm install -g mongosh
            Write-Success "✅ mongosh installed via npm"
        } catch {
            Write-Error-Custom "❌ Failed to install mongosh: $_"
        }
    }
}

# 6. Install MongoDB Compass (GUI)
if (-not $SkipCompass) {
    Write-Info ""
    Write-Info "Step 5: Installing MongoDB Compass (optional GUI)..."
    $compass_installed = $false
    try {
        choco install mongodb-compass -y
        $compass_installed = $true
        Write-Success "✅ MongoDB Compass installed"
    } catch {
        Write-Warning-Custom "⚠️  Failed to install Compass. You can download it from:"
        Write-Info "    https://www.mongodb.com/products/compass"
    }
}

# 7. Verify Installations
Write-Info ""
Write-Info "Step 6: Verifying installations..."

$mongo_version = $null
try {
    $mongo_version = mongosh --version 2>&1 | Select-Object -First 1
    Write-Success "✅ mongosh: $mongo_version"
} catch {
    Write-Warning-Custom "⚠️  Could not verify mongosh version"
}

# 8. Test MongoDB Service
Write-Info ""
Write-Info "Step 7: Checking MongoDB service..."
try {
    $service = Get-Service -Name MongoDB -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq "Running") {
            Write-Success "✅ MongoDB service is running"
        } else {
            Write-Warning-Custom "⚠️  MongoDB service is stopped. Starting..."
            Start-Service -Name MongoDB
            Start-Sleep -Seconds 2
            Write-Success "✅ MongoDB service started"
        }
    } else {
        Write-Warning-Custom "⚠️  MongoDB service not found. Please ensure installation is complete."
    }
} catch {
    Write-Error-Custom "❌ Error checking service: $_"
}

# 9. Create sample .env file
Write-Info ""
Write-Info "Step 8: Creating sample .env file..."
$env_content = @"
# MongoDB Configuration
MONGO_URI=mongodb://localhost:27017
MONGO_DB_NAME=app_db
MONGO_PASSWORD=your_secure_password_here

# Application Configuration
NODE_ENV=development
PORT=3000
"@

$env_file = ".env"
if (-not (Test-Path $env_file)) {
    try {
        $env_content | Out-File -FilePath $env_file -Encoding UTF8
        Write-Success "✅ Created $env_file"
        Write-Warning-Custom "⚠️  Update MONGO_PASSWORD with secure credentials"
    } catch {
        Write-Warning-Custom "⚠️  Could not create .env file: $_"
    }
} else {
    Write-Info "ℹ️  .env file already exists, skipping..."
}

# 10. Install Dev Dependencies
Write-Info ""
Write-Info "Step 9: Installing development dependencies..."
try {
    npm install --save-dev mongodb-memory-server @types/node @types/jest
    Write-Success "✅ Development dependencies installed"
} catch {
    Write-Warning-Custom "⚠️  Some dev dependencies failed: $_"
}

# 11. Create test script
Write-Info ""
Write-Info "Step 10: Creating MongoDB connection test script..."
$test_script = @"
import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';

async function testConnection() {
  const client = new MongoClient(MONGO_URI);
  try {
    console.log('Connecting to MongoDB...');
    await client.connect();
    console.log('✅ MongoDB connected successfully');
    
    const result = await client.db('admin').command({ ping: 1 });
    console.log('✅ Ping response:', result);
    
    const databases = await client.db('admin').admin().listDatabases();
    console.log('✅ Databases count:', databases.databases.length);
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
  } finally {
    await client.close();
  }
}

testConnection();
"@

try {
    $test_script | Out-File -FilePath "test-mongodb-connection.js" -Encoding UTF8
    Write-Success "✅ Created test-mongodb-connection.js"
} catch {
    Write-Warning-Custom "⚠️  Could not create test script: $_"
}

# Final Summary
Write-Info ""
Write-Info "================================"
Write-Success "✅ Installation Complete!"
Write-Info "================================"
Write-Info ""
Write-Info "📋 NEXT STEPS:"
Write-Info ""
Write-Info "1. Verify MongoDB is running:"
Write-Info "   mongosh"
Write-Info ""
Write-Info "2. Test connection from Node.js:"
Write-Info "   node test-mongodb-connection.js"
Write-Info ""
Write-Info "3. Update .env file with your configuration"
Write-Info ""
Write-Info "4. Install application dependencies:"
Write-Info "   npm install"
Write-Info ""
Write-Info "5. Run development server:"
Write-Info "   npm run dev"
Write-Info ""
Write-Info "📚 Resources:"
Write-Info "   - MongoDB Docs: https://docs.mongodb.com/"
Write-Info "   - Connection String: MONGO_URI=mongodb://localhost:27017"
Write-Info ""
Write-Success "✨ Setup complete! Happy coding!"
