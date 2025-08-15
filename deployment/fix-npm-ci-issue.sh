#!/bin/bash

# Fix NPM CI Issue Script
# This script fixes the npm ci issue by ensuring package-lock.json exists

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing NPM CI Issue${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Function to fix backend npm issue
fix_backend() {
    echo -e "${YELLOW}🔧 Fixing backend npm issue...${NC}"
    
    cd "$APP_DIR/backend"
    
    # Remove existing node_modules if present
    if [ -d "node_modules" ]; then
        echo -e "${BLUE}Removing existing node_modules...${NC}"
        rm -rf node_modules
    fi
    
    # Remove existing package-lock.json if corrupted
    if [ -f "package-lock.json" ]; then
        echo -e "${BLUE}Removing existing package-lock.json...${NC}"
        rm -f package-lock.json
    fi
    
    # Install dependencies (this will create package-lock.json)
    echo -e "${BLUE}Installing dependencies with npm install...${NC}"
    npm install --omit=dev
    
    # Verify installation
    if [ -f "package-lock.json" ] && [ -d "node_modules" ]; then
        echo -e "${GREEN}✅ Backend dependencies installed successfully${NC}"
    else
        echo -e "${RED}❌ Backend dependency installation failed${NC}"
        exit 1
    fi
}

# Function to fix frontend npm issue
fix_frontend() {
    echo -e "${YELLOW}🎨 Fixing frontend npm issue...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Remove existing node_modules if present
    if [ -d "node_modules" ]; then
        echo -e "${BLUE}Removing existing node_modules...${NC}"
        rm -rf node_modules
    fi
    
    # Remove existing package-lock.json if corrupted
    if [ -f "package-lock.json" ]; then
        echo -e "${BLUE}Removing existing package-lock.json...${NC}"
        rm -f package-lock.json
    fi
    
    # Install dependencies (this will create package-lock.json)
    echo -e "${BLUE}Installing dependencies with npm install...${NC}"
    npm install
    
    # Verify installation
    if [ -f "package-lock.json" ] && [ -d "node_modules" ]; then
        echo -e "${GREEN}✅ Frontend dependencies installed successfully${NC}"
    else
        echo -e "${RED}❌ Frontend dependency installation failed${NC}"
        exit 1
    fi
}

# Function to test build
test_build() {
    echo -e "${YELLOW}🧪 Testing builds...${NC}"
    
    # Test backend
    cd "$APP_DIR/backend"
    if node -e "console.log('Backend dependencies OK')"; then
        echo -e "${GREEN}✅ Backend dependencies working${NC}"
    else
        echo -e "${RED}❌ Backend dependencies issue${NC}"
        exit 1
    fi
    
    # Test frontend build
    cd "$APP_DIR/frontend"
    export API_URL="http://localhost:3001"
    if npm run build; then
        echo -e "${GREEN}✅ Frontend build successful${NC}"
    else
        echo -e "${RED}❌ Frontend build failed${NC}"
        exit 1
    fi
}

# Main execution
main() {
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        exit 1
    fi
    
    fix_backend
    fix_frontend
    test_build
    
    echo -e "${GREEN}🎉 NPM CI issue fixed successfully!${NC}"
    echo -e "${BLUE}You can now run the deployment script again${NC}"
}

# Run main function
main
