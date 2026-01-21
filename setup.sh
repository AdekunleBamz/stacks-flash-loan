#!/usr/bin/env bash

# Stacks Flash Loan Setup Script

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

print_info "Setting up Stacks Flash Loan..."

if ! command_exists node; then
  print_warning "Node.js not found. Install Node.js 18+ to run tests."
else
  print_success "Node.js found."
fi

if command_exists npm; then
  print_info "Installing dependencies..."
  npm install
  print_success "Dependencies installed."
else
  print_warning "npm not found. Install npm to proceed."
fi

if ! command_exists clarinet; then
  print_warning "Clarinet not found. Install with: npm i -g @hirosystems/clarinet"
else
  print_success "Clarinet found."
fi

if [[ ! -f ".env" ]]; then
  cat > .env << EOF
# Stacks Flash Loan env
STACKS_NETWORK=mocknet
CLARINET_DIR=.clarinet
EOF
  print_success ".env created."
else
  print_info ".env already exists."
fi

print_success "Setup complete."
echo ""
print_info "Next steps:"
echo "  1. Run checks: make check"
echo "  2. Run tests: make test"
echo "  3. Open console: make console"