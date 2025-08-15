#!/bin/bash

# Test Deployment Script
# This script tests the deployed services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Giovanni Amodeo Deployment${NC}"

# Function to test endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -e "${YELLOW}Testing $name: $url${NC}"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "$expected_status" ]; then
        echo -e "${GREEN}✅ $name: HTTP $HTTP_CODE${NC}"
        return 0
    else
        echo -e "${RED}❌ $name: HTTP $HTTP_CODE (expected $expected_status)${NC}"
        return 1
    fi
}

# Function to test JSON endpoint
test_json_endpoint() {
    local url=$1
    local name=$2
    
    echo -e "${YELLOW}Testing $name: $url${NC}"
    
    RESPONSE=$(curl -s "$url" 2>/dev/null || echo "")
    
    if echo "$RESPONSE" | jq . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name: Valid JSON response${NC}"
        echo "$RESPONSE" | jq . | head -n 5
        return 0
    else
        echo -e "${RED}❌ $name: Invalid JSON response${NC}"
        echo "Response: $RESPONSE"
        return 1
    fi
}

# Main tests
main() {
    echo -e "${BLUE}🔍 Running deployment tests...${NC}"
    
    BACKEND_URL="http://localhost:3001"
    FRONTEND_URL="http://localhost"
    
    # Test backend endpoints
    echo -e "${BLUE}Backend Tests:${NC}"
    test_json_endpoint "$BACKEND_URL/api/health" "Backend Health"
    test_json_endpoint "$BACKEND_URL/api/docs" "API Documentation"
    test_json_endpoint "$BACKEND_URL/api/videos" "Videos API"
    test_endpoint "$BACKEND_URL/" "Backend Root" 200
    
    echo ""
    
    # Test frontend endpoints
    echo -e "${BLUE}Frontend Tests:${NC}"
    test_endpoint "$FRONTEND_URL/" "Frontend Home" 200
    test_endpoint "$FRONTEND_URL/admin/" "Admin Panel" 200
    
    echo ""
    
    # Test proxy endpoints
    echo -e "${BLUE}Proxy Tests:${NC}"
    test_json_endpoint "$FRONTEND_URL/api/health" "Proxied Health Check"
    test_json_endpoint "$FRONTEND_URL/api/videos" "Proxied Videos API"
    
    echo ""
    
    # Test services
    echo -e "${BLUE}Service Status:${NC}"
    
    # PM2 status
    if pm2 list | grep -q giovanni-backend; then
        echo -e "${GREEN}✅ PM2 service running${NC}"
    else
        echo -e "${RED}❌ PM2 service not found${NC}"
    fi
    
    # Nginx status
    if sudo systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Nginx service running${NC}"
    else
        echo -e "${RED}❌ Nginx service not running${NC}"
    fi
    
    # Port checks
    echo -e "${BLUE}Port Status:${NC}"
    if netstat -tlnp 2>/dev/null | grep :3001 >/dev/null; then
        echo -e "${GREEN}✅ Backend port 3001 active${NC}"
    else
        echo -e "${RED}❌ Backend port 3001 not active${NC}"
    fi
    
    if netstat -tlnp 2>/dev/null | grep :80 >/dev/null; then
        echo -e "${GREEN}✅ Frontend port 80 active${NC}"
    else
        echo -e "${RED}❌ Frontend port 80 not active${NC}"
    fi
    
    echo -e "${GREEN}🎉 Deployment test completed!${NC}"
}

# Run tests
main
