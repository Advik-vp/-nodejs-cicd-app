#!/bin/bash

# GitHub MongoDB CI/CD Setup Script
# This script helps you set up GitHub Secrets for MongoDB CI/CD integration

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo ""
log_info "================================"
log_info "GitHub MongoDB CI/CD Setup"
log_info "================================"
log_info ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed"
    log_warning "Please install GitHub CLI from: https://cli.github.com"
    log_info "Then run: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status > /dev/null 2>&1; then
    log_error "Not authenticated with GitHub"
    log_info "Please run: gh auth login"
    exit 1
fi

log_success "GitHub CLI authenticated"
log_info ""

# Get current repository
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
log_info "Repository: $REPO"
log_info ""

# Step 1: Add MONGO_PASSWORD secret
log_info "Step 1: Add MONGO_PASSWORD secret"
log_info "This password will be used for MongoDB in CI/CD tests"
log_info ""

read -sp "Enter MongoDB password for CI/CD: " MONGO_PASSWORD
echo ""

if [ -z "$MONGO_PASSWORD" ]; then
    log_error "Password cannot be empty"
    exit 1
fi

# Generate secure password if empty
if [ ${#MONGO_PASSWORD} -lt 8 ]; then
    log_warning "Password is short. Consider a stronger password"
fi

log_info "Setting MONGO_PASSWORD secret..."
echo -n "$MONGO_PASSWORD" | gh secret set MONGO_PASSWORD --repo "$REPO"
log_success "✅ MONGO_PASSWORD secret set"
log_info ""

# Step 2: Verify secret was set
log_info "Step 2: Verifying secrets..."
SECRETS=$(gh secret list --repo "$REPO" --json name --jq '.[].name')

if echo "$SECRETS" | grep -q "MONGO_PASSWORD"; then
    log_success "MONGO_PASSWORD is set"
else
    log_error "Failed to set MONGO_PASSWORD"
    exit 1
fi

log_info ""

# Step 3: Check workflows
log_info "Step 3: Checking GitHub Actions workflows..."
WORKFLOWS=$(gh workflow list --repo "$REPO" --json name --jq '.[].name')

echo "Available workflows:"
echo "$WORKFLOWS"
log_info ""

if echo "$WORKFLOWS" | grep -q "CI/CD Pipeline"; then
    log_success "CI/CD Pipeline workflow found"
else
    log_warning "CI/CD Pipeline workflow not found"
fi

if echo "$WORKFLOWS" | grep -q "MongoDB Integration"; then
    log_success "MongoDB Integration workflow found"
else
    log_warning "MongoDB Integration workflow not found"
fi

log_info ""

# Step 4: Next steps
log_info "Step 4: Ready to deploy"
log_info ""
log_info "Next steps:"
log_info "1. Push your code to GitHub:"
log_info "   git add ."
log_info "   git commit -m 'Add MongoDB CI/CD integration'"
log_info "   git push origin main"
log_info ""
log_info "2. View your workflows:"
log_info "   gh workflow view ci-cd.yml"
log_info "   gh workflow view mongodb-integration.yml"
log_info ""
log_info "3. Monitor your first run:"
log_info "   gh run list"
log_info "   gh run view <run-id>"
log_info ""
log_info "4. View live on GitHub:"
log_info "   https://github.com/$REPO/actions"
log_info ""

# Step 5: Optional - Trigger workflow
read -p "Do you want to trigger workflows now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Triggering workflows..."
    gh workflow run ci-cd.yml --repo "$REPO"
    log_success "CI/CD Pipeline triggered"
    gh workflow run mongodb-integration.yml --repo "$REPO"
    log_success "MongoDB Integration triggered"
    log_info ""
    log_info "View progress at: https://github.com/$REPO/actions"
fi

log_info ""
log_success "================================"
log_success "Setup Complete! 🎉"
log_success "================================"
log_info ""
log_info "Your GitHub CI/CD now has:"
log_info "✅ Automated MongoDB testing"
log_info "✅ Performance monitoring"
log_info "✅ Security scanning"
log_info "✅ Docker integration"
log_info "✅ Daily scheduled runs"
log_info ""
log_success "Happy coding!"
