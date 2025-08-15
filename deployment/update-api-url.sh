#!/bin/bash

# Update API URL Script
# This script updates the frontend to use the EC2 server IP instead of localhost

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Updating API URL Configuration${NC}"

APP_DIR="/var/www/giovanni-amodeo"
EC2_IP="13.232.27.48"
API_URL="http://${EC2_IP}"

# Function to update frontend API configuration
update_frontend_api() {
    echo -e "${YELLOW}📝 Updating frontend API configuration...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Check if API file exists
    if [ -f "src/lib/api.js" ]; then
        # Update API_BASE_URL in the API client
        sed -i "s|const API_BASE_URL = import.meta.env.API_URL || 'http://localhost:3001'|const API_BASE_URL = import.meta.env.API_URL || '${API_URL}'|g" src/lib/api.js
        
        echo -e "${GREEN}✅ Updated API URL in frontend/src/lib/api.js${NC}"
    else
        echo -e "${RED}❌ API file not found: src/lib/api.js${NC}"
        return 1
    fi
    
    # Update environment template
    if [ -f "env.example" ]; then
        sed -i "s|API_URL=http://localhost:3001|API_URL=${API_URL}|g" env.example
        echo -e "${GREEN}✅ Updated API URL in frontend/env.example${NC}"
    fi
    
    # Create .env file with production settings
    cat > .env << EOF
# Frontend Environment Variables
API_URL=${API_URL}
NODE_ENV=production
EOF
    
    echo -e "${GREEN}✅ Created frontend/.env with production API URL${NC}"
}

# Function to rebuild frontend with new API URL
rebuild_frontend() {
    echo -e "${YELLOW}🔨 Rebuilding frontend with updated API URL...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Set environment variable for build
    export API_URL="${API_URL}"
    
    # Clean previous build
    rm -rf dist
    
    # Ensure public assets are available
    if [ ! -d "public" ] && [ -d "../public" ]; then
        echo -e "${BLUE}📁 Copying public assets...${NC}"
        cp -r ../public .
    fi
    
    # Build frontend
    if npm run build; then
        echo -e "${GREEN}✅ Frontend rebuilt successfully${NC}"
        
        # Verify build output
        if [ -d "dist" ]; then
            TOTAL_FILES=$(find dist -type f 2>/dev/null | wc -l || echo "0")
            BUILD_SIZE=$(du -sh dist 2>/dev/null | cut -f1 || echo "unknown")
            
            echo -e "${BLUE}📊 Build Statistics:${NC}"
            echo -e "${BLUE}   • Total files: $TOTAL_FILES${NC}"
            echo -e "${BLUE}   • Build size: $BUILD_SIZE${NC}"
        else
            echo -e "${RED}❌ Build output directory not created${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Frontend build failed${NC}"
        return 1
    fi
}

# Function to restart nginx
restart_nginx() {
    echo -e "${YELLOW}🌐 Restarting Nginx...${NC}"
    
    # Test nginx configuration
    if sudo nginx -t; then
        echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
        
        # Restart nginx
        if sudo systemctl restart nginx; then
            echo -e "${GREEN}✅ Nginx restarted successfully${NC}"
        else
            echo -e "${RED}❌ Failed to restart Nginx${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Nginx configuration test failed${NC}"
        return 1
    fi
}

# Function to test API connectivity
test_api_connectivity() {
    echo -e "${YELLOW}🧪 Testing API connectivity...${NC}"
    
    # Test backend API directly
    echo -e "${BLUE}Testing backend API at ${API_URL}/api/videos...${NC}"
    
    if curl -s --max-time 10 "${API_URL}/api/videos" | grep -q '"success":true'; then
        echo -e "${GREEN}✅ Backend API is responding correctly${NC}"
    else
        echo -e "${RED}❌ Backend API test failed${NC}"
        echo -e "${YELLOW}⚠️  Checking if backend is running...${NC}"
        
        # Check PM2 status
        pm2 status | grep giovanni-backend || echo -e "${RED}❌ Backend not found in PM2${NC}"
        
        return 1
    fi
    
    # Test frontend access
    echo -e "${BLUE}Testing frontend access at http://localhost/...${NC}"
    
    if curl -s --max-time 10 "http://localhost/" | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✅ Frontend is accessible via Nginx${NC}"
    else
        echo -e "${RED}❌ Frontend access test failed${NC}"
        return 1
    fi
}

# Function to show deployment info
show_deployment_info() {
    echo -e "${GREEN}🎉 API URL Update Complete!${NC}"
    echo -e "${BLUE}📋 Updated Configuration:${NC}"
    echo -e "${BLUE}   • Frontend API URL: ${API_URL}${NC}"
    echo -e "${BLUE}   • Backend API: ${API_URL}/api/videos${NC}"
    echo -e "${BLUE}   • Frontend URL: http://${EC2_IP}/${NC}"
    echo ""
    echo -e "${YELLOW}📚 Next Steps:${NC}"
    echo -e "${YELLOW}   1. Test your website: http://${EC2_IP}/${NC}"
    echo -e "${YELLOW}   2. Check API: http://${EC2_IP}/api/videos${NC}"
    echo -e "${YELLOW}   3. Monitor logs: pm2 logs giovanni-backend${NC}"
    echo -e "${YELLOW}   4. Check Nginx logs: sudo tail -f /var/log/nginx/giovanni-amodeo.access.log${NC}"
}

# Main execution
main() {
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        echo -e "${YELLOW}Please ensure the application is deployed first.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Updating Giovanni Amodeo API Configuration${NC}"
    echo -e "${BLUE}   • EC2 IP: ${EC2_IP}${NC}"
    echo -e "${BLUE}   • API URL: ${API_URL}${NC}"
    echo ""
    
    # Update frontend API configuration
    update_frontend_api
    
    echo ""
    
    # Rebuild frontend
    rebuild_frontend
    
    echo ""
    
    # Restart nginx to serve new frontend build
    restart_nginx
    
    echo ""
    
    # Test connectivity
    test_api_connectivity
    
    echo ""
    
    # Show deployment info
    show_deployment_info
}

# Run main function
main
