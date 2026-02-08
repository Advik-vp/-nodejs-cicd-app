#!/bin/bash

# MongoDB Dependencies Installation Script for macOS & Linux
# ===========================================================
# Automatically detects OS and installs appropriate packages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "ubuntu"
        elif [ -f /etc/redhat-release ]; then
            echo "centos"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Start
log_info "================================"
log_info "MongoDB Installation Script"
log_info "================================"
log_info ""

OS=$(detect_os)
log_info "Detected OS: $OS"
log_info ""

# Step 1: NPM Package Installation
log_info "Step 1: Installing NPM packages..."
if command_exists npm; then
    npm install mongodb@^6.3.0 dotenv@^16.3.1
    log_success "NPM packages installed successfully"
else
    log_error "npm not found. Please install Node.js first."
    exit 1
fi

# Step 2: MongoDB Server Installation
log_info ""
log_info "Step 2: Installing MongoDB Community Edition..."

case $OS in
    macos)
        log_info "macOS detected. Using Homebrew..."
        
        # Check if Homebrew is installed
        if ! command_exists brew; then
            log_error "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Tap MongoDB tap
        brew tap mongodb/brew
        
        # Install MongoDB
        brew install mongodb-community
        log_success "MongoDB Community Edition installed"
        
        # Start MongoDB service
        log_info "Starting MongoDB service..."
        brew services start mongodb-community
        log_success "MongoDB service started"
        ;;
        
    ubuntu)
        log_info "Ubuntu detected. Using apt package manager..."
        
        # Check for root/sudo
        if [ "$EUID" -ne 0 ]; then
            log_error "Ubuntu installation requires root privileges. Please run with sudo."
            exit 1
        fi
        
        # Add MongoDB GPG key
        log_info "Adding MongoDB GPG key..."
        curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -
        
        # Add MongoDB repository
        log_info "Adding MongoDB repository..."
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        
        # Update package list
        apt-get update
        
        # Install MongoDB
        log_info "Installing MongoDB Community Edition..."
        apt-get install -y mongodb-org
        log_success "MongoDB Community Edition installed"
        
        # Start and enable service
        log_info "Starting MongoDB service..."
        systemctl start mongod
        systemctl enable mongod
        log_success "MongoDB service started and enabled"
        ;;
        
    centos)
        log_info "CentOS/RHEL detected. Using yum package manager..."
        
        # Check for root/sudo
        if [ "$EUID" -ne 0 ]; then
            log_error "CentOS installation requires root privileges. Please run with sudo."
            exit 1
        fi
        
        # Add MongoDB repository
        log_info "Adding MongoDB repository..."
        cat > /etc/yum.repos.d/mongodb-org-7.0.repo << 'EOF'
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF
        
        # Install MongoDB
        log_info "Installing MongoDB Community Edition..."
        yum install -y mongodb-org
        log_success "MongoDB Community Edition installed"
        
        # Start and enable service
        log_info "Starting MongoDB service..."
        systemctl start mongod
        systemctl enable mongod
        log_success "MongoDB service started and enabled"
        ;;
        
    *)
        log_error "Unsupported OS detected. Please install MongoDB manually."
        log_info "Visit: https://docs.mongodb.com/manual/installation/"
        exit 1
        ;;
esac

# Step 3: Install mongosh
log_info ""
log_info "Step 3: Installing mongosh (MongoDB Shell)..."

if ! command_exists mongosh; then
    case $OS in
        macos)
            brew install mongosh
            ;;
        ubuntu)
            if [ "$EUID" -eq 0 ]; then
                curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -
                echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
                apt-get update
                apt-get install -y mongosh
            fi
            ;;
        centos)
            if [ "$EUID" -eq 0 ]; then
                yum install -y mongosh
            fi
            ;;
    esac
    
    if command_exists mongosh; then
        log_success "mongosh installed successfully"
    else
        log_warning "mongosh installation failed. Trying npm..."
        npm install -g mongosh || log_warning "mongosh installation skipped"
    fi
else
    log_info "mongosh already installed"
fi

# Step 4: Install Development Dependencies
log_info ""
log_info "Step 4: Installing development dependencies..."
npm install --save-dev mongodb-memory-server @types/node @types/jest
log_success "Development dependencies installed"

# Step 5: Create .env file
log_info ""
log_info "Step 5: Creating .env file..."

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    cat > "$ENV_FILE" << 'EOF'
# MongoDB Configuration
MONGO_URI=mongodb://localhost:27017
MONGO_DB_NAME=app_db
MONGO_PASSWORD=your_secure_password_here

# Application Configuration
NODE_ENV=development
PORT=3000
EOF
    log_success "Created $ENV_FILE"
    log_warning "Update MONGO_PASSWORD with secure credentials"
else
    log_info "$ENV_FILE already exists, skipping..."
fi

# Step 6: Create test script
log_info ""
log_info "Step 6: Creating MongoDB connection test script..."

cat > test-mongodb-connection.js << 'EOF'
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
EOF

chmod +x test-mongodb-connection.js
log_success "Created test-mongodb-connection.js"

# Step 7: Verify Installations
log_info ""
log_info "Step 7: Verifying installations..."

if command_exists mongosh; then
    MONGO_VERSION=$(mongosh --version 2>&1 | head -1)
    log_success "mongosh: $MONGO_VERSION"
else
    log_warning "mongosh not found in PATH"
fi

# Step 8: Test MongoDB Connection
log_info ""
log_info "Step 8: Testing MongoDB connection..."

if command_exists mongosh; then
    if mongosh --eval "db.runCommand('ping')" >/dev/null 2>&1; then
        log_success "MongoDB is running and responding"
    else
        log_warning "MongoDB service may not be running. Start with:"
        case $OS in
            macos)
                log_info "  brew services start mongodb-community"
                ;;
            ubuntu|centos)
                log_info "  sudo systemctl start mongod"
                ;;
        esac
    fi
else
    log_warning "Could not test connection (mongosh not found)"
fi

# Summary
log_info ""
log_info "================================"
log_success "Installation Complete!"
log_info "================================"
log_info ""
log_info "📋 NEXT STEPS:"
log_info ""
log_info "1. Verify MongoDB is running:"
log_info "   mongosh"
log_info ""
log_info "2. Test connection from Node.js:"
log_info "   node test-mongodb-connection.js"
log_info ""
log_info "3. Update .env file with your configuration"
log_info ""
log_info "4. Install application dependencies:"
log_info "   npm install"
log_info ""
log_info "5. Run development server:"
log_info "   npm run dev"
log_info ""
log_info "📚 Resources:"
log_info "   - MongoDB Docs: https://docs.mongodb.com/"
log_info "   - Connection String: MONGO_URI=mongodb://localhost:27017"
log_info ""
log_success "✨ Setup complete! Happy coding!"
