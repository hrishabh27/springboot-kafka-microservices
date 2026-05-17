#!/bin/bash
# =============================================================================
# DATABASE INITIALIZATION SCRIPT
# Description: Initializes all MySQL databases with schema and seed data
# Usage: ./init-db.sh [--env-file .env]
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENV_FILE=".env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--env-file .env]"
            echo ""
            echo "Options:"
            echo "  --env-file   Path to environment file (default: .env)"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Load environment variables
# -----------------------------------------------------------------------------
if [[ -f "$PROJECT_ROOT/$ENV_FILE" ]]; then
    echo -e "${YELLOW}Loading environment from $ENV_FILE...${NC}"
    set -a
    source "$PROJECT_ROOT/$ENV_FILE"
    set +a
else
    echo -e "${YELLOW}Warning: $ENV_FILE not found. Using default values.${NC}"
    # Default values
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-3306}"
    DB_USERNAME="${DB_USERNAME:-root}"
    DB_PASSWORD="${DB_PASSWORD:-root}"
fi

# Use environment variables or defaults
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USERNAME="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
DB_NAME_USER="${DB_NAME_USER:-user_db}"
DB_NAME_PRODUCT="${DB_NAME_PRODUCT:-product_db}"
DB_NAME_ORDER="${DB_NAME_ORDER:-order_db}"
DB_NAME_PAYMENT="${DB_NAME_PAYMENT:-payment_db}"

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "  E-Commerce Microservices - Database Setup"
echo "=================================================="
echo ""

# Check if MySQL client is available
if ! command -v mysql &> /dev/null; then
    print_error "MySQL client not found. Please install MySQL client."
    exit 1
fi

# Test MySQL connection
print_info "Testing MySQL connection..."
if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1" &> /dev/null; then
    print_success "MySQL connection successful"
else
    print_error "Failed to connect to MySQL. Please check your credentials."
    exit 1
fi

# -----------------------------------------------------------------------------
# Create databases and run scripts
# -----------------------------------------------------------------------------
print_info "Creating databases and initializing schema..."

# Run user_db script
print_info "Initializing user_db..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" < "$SCRIPT_DIR/sql/01_user_db.sql" 2>/dev/null
print_success "user_db initialized"

# Run product_db script
print_info "Initializing product_db..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" < "$SCRIPT_DIR/sql/02_product_db.sql" 2>/dev/null
print_success "product_db initialized"

# Run order_db script
print_info "Initializing order_db..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" < "$SCRIPT_DIR/sql/03_order_db.sql" 2>/dev/null
print_success "order_db initialized"

# -----------------------------------------------------------------------------
# Verify databases
# -----------------------------------------------------------------------------
echo ""
print_info "Verifying databases..."
DATABASES=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -N -e "SHOW DATABASES" 2>/dev/null | grep -E "_db$")

echo ""
echo "Databases created:"
echo "$DATABASES" | while read db; do
    print_success "  - $db"
done

echo ""
echo "=================================================="
echo "  Database Setup Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env and update values"
echo "  2. Run ./start-services.sh to start all services"
echo ""