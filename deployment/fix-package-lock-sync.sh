#!/bin/bash

# Fix Package Lock Sync Issue Script
# This script fixes package.json and package-lock.json sync issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing Package Lock Sync Issues${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Function to fix sync issues
fix_sync_issues() {
    local dir=$1
    local service_name=$2
    
    echo -e "${YELLOW}🔧 Fixing $service_name sync issues...${NC}"
    
    cd "$APP_DIR/$dir"
    
    # Show current status
    echo -e "${BLUE}Current status in $dir:${NC}"
    if [ -f "package.json" ]; then
        echo -e "${GREEN}✅ package.json exists${NC}"
    else
        echo -e "${RED}❌ package.json missing${NC}"
        return 1
    fi
    
    if [ -f "package-lock.json" ]; then
        echo -e "${YELLOW}⚠️  package-lock.json exists (might be out of sync)${NC}"
    else
        echo -e "${BLUE}ℹ️  No package-lock.json found${NC}"
    fi
    
    # Clean install to fix sync issues
    echo -e "${BLUE}Cleaning and reinstalling dependencies...${NC}"
    
    # Remove problematic files
    rm -rf node_modules
    rm -f package-lock.json
    rm -f npm-shrinkwrap.json
    
    # Clean npm cache
    npm cache clean --force 2>/dev/null || true
    
    # Fresh install
    if [ "$service_name" = "backend" ]; then
        npm install --omit=dev
    else
        npm install
    fi
    
    # Verify installation
    if [ -f "package-lock.json" ] && [ -d "node_modules" ]; then
        echo -e "${GREEN}✅ $service_name dependencies synced successfully${NC}"
        
        # Show some stats
        PACKAGES=$(ls node_modules | wc -l)
        echo -e "${BLUE}Installed $PACKAGES packages${NC}"
    else
        echo -e "${RED}❌ $service_name dependency sync failed${NC}"
        return 1
    fi
}

# Function to test installations
test_installations() {
    echo -e "${YELLOW}🧪 Testing installations...${NC}"
    
    # Test backend
    cd "$APP_DIR/backend"
    if node -e "console.log('Backend Node.js check: OK')"; then
        echo -e "${GREEN}✅ Backend Node.js working${NC}"
    else
        echo -e "${RED}❌ Backend Node.js issue${NC}"
        return 1
    fi
    
    # Test backend dependencies
    if node -e "require('express'); console.log('Backend dependencies: OK')"; then
        echo -e "${GREEN}✅ Backend dependencies working${NC}"
    else
        echo -e "${RED}❌ Backend dependencies issue${NC}"
        return 1
    fi
    
    # Test frontend build
    cd "$APP_DIR/frontend"
    
    # Ensure public assets are available
    if [ ! -d "public" ] && [ -d "../public" ]; then
        echo -e "${BLUE}📁 Copying public assets for frontend build...${NC}"
        cp -r ../public .
    fi
    
    export API_URL="http://13.232.27.48"
    
    echo -e "${BLUE}Testing frontend build...${NC}"
    if timeout 120 npm run build; then
        echo -e "${GREEN}✅ Frontend build successful${NC}"
        
        if [ -d "dist" ]; then
            echo -e "${GREEN}✅ Frontend dist directory created${NC}"
        else
            echo -e "${RED}❌ Frontend dist directory missing${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Frontend build failed or timed out${NC}"
        return 1
    fi
}

# Function to show summary
show_summary() {
    echo -e "${GREEN}🎉 Package Lock Sync Issues Fixed!${NC}"
    echo -e "${BLUE}📋 Summary:${NC}"
    
    # Backend summary
    cd "$APP_DIR/backend"
    BACKEND_PACKAGES=$(ls node_modules 2>/dev/null | wc -l || echo "0")
    echo -e "${BLUE}   • Backend: $BACKEND_PACKAGES packages installed${NC}"
    
    # Frontend summary  
    cd "$APP_DIR/frontend"
    FRONTEND_PACKAGES=$(ls node_modules 2>/dev/null | wc -l || echo "0")
    echo -e "${BLUE}   • Frontend: $FRONTEND_PACKAGES packages installed${NC}"
    
    if [ -d "dist" ]; then
        DIST_FILES=$(find dist -type f 2>/dev/null | wc -l || echo "0")
        echo -e "${BLUE}   • Frontend dist: $DIST_FILES files generated${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}📚 Next steps:${NC}"
    echo -e "${YELLOW}   1. Run: ./deployment/deploy.sh deploy${NC}"
    echo -e "${YELLOW}   2. Test: ./deployment/test-deployment.sh${NC}"
}

# Main execution
main() {
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        exit 1
    fi
    
    # Fix backend sync issues
    fix_sync_issues "backend" "backend"
    
    echo ""
    
    # Fix frontend sync issues
    fix_sync_issues "frontend" "frontend"
    
    echo ""
    
    # Test installations
    test_installations
    
    echo ""
    
    # Show summary
    show_summary
}

# Run main function
main
