# GitHub MongoDB CI/CD Setup Script - Windows PowerShell
# This script helps you set up GitHub Secrets for MongoDB CI/CD integration

param(
    [string]$MongoPassword = "",
    [switch]$SkipVerification = $false
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning-Custom { Write-Host $args -ForegroundColor Yellow }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }

Write-Info ""
Write-Info "========================================"
Write-Info "GitHub MongoDB CI/CD Setup"
Write-Info "========================================"
Write-Info ""

# Step 1: Check if GitHub CLI is installed
Write-Info "Step 1: Checking GitHub CLI..."
try {
    $ghVersion = gh --version 2>$null
    Write-Success "✅ GitHub CLI found: $ghVersion"
} catch {
    Write-Error-Custom "❌ GitHub CLI not found"
    Write-Info "Please install GitHub CLI from: https://cli.github.com"
    Write-Info "Then run: gh auth login"
    exit 1
}

# Step 2: Check authentication
Write-Info ""
Write-Info "Step 2: Checking GitHub authentication..."
try {
    $auth = gh auth status 2>&1
    Write-Success "✅ GitHub CLI authenticated"
} catch {
    Write-Error-Custom "❌ Not authenticated with GitHub"
    Write-Info "Please run: gh auth login"
    exit 1
}

# Step 3: Get current repository
Write-Info ""
Write-Info "Step 3: Detecting repository..."
$repo = gh repo view --json nameWithOwner --jq .nameWithOwner 2>$null
if ($repo) {
    Write-Success "✅ Repository: $repo"
} else {
    Write-Error-Custom "❌ Could not determine repository"
    Write-Info "Make sure you're in a git repository directory"
    exit 1
}

# Step 4: Get MongoDB password
Write-Info ""
Write-Info "Step 4: Setting MongoDB password"
Write-Info "This password will be used for MongoDB in CI/CD tests"
Write-Info ""

if (-not $MongoPassword) {
    $password = Read-Host "Enter MongoDB password for CI/CD" -AsSecureString
    $MongoPassword = [System.Net.NetworkCredential]::new('', $password).Password
    
    if (-not $MongoPassword) {
        Write-Error-Custom "❌ Password cannot be empty"
        exit 1
    }
    
    if ($MongoPassword.Length -lt 8) {
        Write-Warning-Custom "⚠️  Password is short. Consider a stronger password"
    }
}

# Step 5: Set the secret
Write-Info ""
Write-Info "Setting MONGO_PASSWORD secret..."
$MongoPassword | gh secret set MONGO_PASSWORD --repo "$repo"

if ($LASTEXITCODE -eq 0) {
    Write-Success "✅ MONGO_PASSWORD secret set successfully"
} else {
    Write-Error-Custom "❌ Failed to set MONGO_PASSWORD"
    exit 1
}

# Step 6: Verify secret
if (-not $SkipVerification) {
    Write-Info ""
    Write-Info "Step 5: Verifying secrets..."
    $secrets = gh secret list --repo "$repo" --json name --jq '.[].name'
    
    if ($secrets -match "MONGO_PASSWORD") {
        Write-Success "✅ MONGO_PASSWORD is set and verified"
    } else {
        Write-Warning-Custom "⚠️  Could not verify secret"
    }
}

# Step 7: List workflows
Write-Info ""
Write-Info "Step 6: Checking GitHub Actions workflows..."
Write-Info ""

$workflows = gh workflow list --repo "$repo" --json name --jq '.[].name'
Write-Info "Available workflows:"
$workflows | ForEach-Object { Write-Info "  - $_" }
Write-Info ""

if ($workflows -match "CI/CD Pipeline") {
    Write-Success "✅ CI/CD Pipeline workflow found"
} else {
    Write-Warning-Custom "⚠️  CI/CD Pipeline workflow not found"
}

if ($workflows -match "MongoDB Integration") {
    Write-Success "✅ MongoDB Integration workflow found"
} else {
    Write-Warning-Custom "⚠️  MongoDB Integration workflow not found"
}

# Step 8: Display next steps
Write-Info ""
Write-Success "========================================"
Write-Success "Setup Complete! 🎉"
Write-Success "========================================"
Write-Info ""
Write-Info "Next steps:"
Write-Info ""
Write-Info "1. Push your code to GitHub:"
Write-Info "   git add ."
Write-Info "   git commit -m 'Add MongoDB CI/CD integration'"
Write-Info "   git push origin main"
Write-Info ""
Write-Info "2. View your workflows:"
Write-Info "   gh workflow view ci-cd.yml"
Write-Info "   gh workflow view mongodb-integration.yml"
Write-Info ""
Write-Info "3. Monitor your first run:"
Write-Info "   gh run list"
Write-Info "   gh run view <run-id>"
Write-Info ""
Write-Info "4. View live on GitHub:"
Write-Info "   https://github.com/$repo/actions"
Write-Info ""

# Step 9: Optional - Trigger workflow
Write-Info ""
$trigger = Read-Host "Do you want to trigger workflows now? (y/n)"
if ($trigger -eq "y" -or $trigger -eq "Y") {
    Write-Info ""
    Write-Info "Triggering workflows..."
    
    gh workflow run ci-cd.yml --repo "$repo"
    Write-Success "✅ CI/CD Pipeline triggered"
    
    gh workflow run mongodb-integration.yml --repo "$repo"
    Write-Success "✅ MongoDB Integration triggered"
    
    Write-Info ""
    Write-Info "View progress at: https://github.com/$repo/actions"
}

Write-Info ""
Write-Info "Your GitHub CI/CD now has:"
Write-Success "✅ Automated MongoDB testing"
Write-Success "✅ Performance monitoring"
Write-Success "✅ Security scanning"
Write-Success "✅ Docker integration"
Write-Success "✅ Daily scheduled runs"
Write-Info ""
Write-Success "Happy coding! 🚀"
