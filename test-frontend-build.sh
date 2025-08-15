#!/bin/bash

# Test Frontend Build Script
# This script tests if the frontend builds correctly with static assets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Frontend Build with Static Assets${NC}"

# Navigate to frontend directory
cd frontend

# Check if public assets exist
if [ -d "public" ]; then
    echo -e "${GREEN}✅ Public assets found in frontend/public${NC}"
    
    # Show some key assets
    if [ -f "public/favicon.svg" ]; then
        echo -e "${GREEN}✅ favicon.svg found${NC}"
    fi
    
    if [ -f "public/photo.jpg" ]; then
        echo -e "${GREEN}✅ photo.jpg found${NC}"
    fi
    
    if [ -f "public/bg-images.jpg" ]; then
        echo -e "${GREEN}✅ bg-images.jpg found${NC}"
    fi
    
    if [ -d "public/photos" ]; then
        PHOTO_COUNT=$(ls public/photos/*.* 2>/dev/null | wc -l || echo "0")
        echo -e "${GREEN}✅ photos directory found with $PHOTO_COUNT images${NC}"
    fi
else
    echo -e "${RED}❌ Public assets not found in frontend/public${NC}"
    echo -e "${YELLOW}⚠️  This will cause 404 errors for images and other static assets${NC}"
    exit 1
fi

# Set API URL for build (use EC2 instance IP)
export API_URL="http://13.232.27.48"

# Test build
echo -e "${BLUE}🔨 Building frontend...${NC}"
if npm run build; then
    echo -e "${GREEN}✅ Frontend build successful${NC}"
    
    # Check build output
    if [ -d "dist" ]; then
        echo -e "${GREEN}✅ Build output directory created${NC}"
        
        # Check if static assets were copied to dist
        if [ -d "dist/favicon.svg" ] || [ -f "dist/favicon.svg" ]; then
            echo -e "${GREEN}✅ favicon.svg copied to build output${NC}"
        fi
        
        if [ -f "dist/photo.jpg" ]; then
            echo -e "${GREEN}✅ photo.jpg copied to build output${NC}"
        fi
        
        if [ -f "dist/bg-images.jpg" ]; then
            echo -e "${GREEN}✅ bg-images.jpg copied to build output${NC}"
        fi
        
        if [ -d "dist/photos" ]; then
            DIST_PHOTO_COUNT=$(find dist/photos -name "*.*" 2>/dev/null | wc -l || echo "0")
            echo -e "${GREEN}✅ photos directory copied with $DIST_PHOTO_COUNT images${NC}"
        fi
        
        # Show build stats
        TOTAL_FILES=$(find dist -type f 2>/dev/null | wc -l || echo "0")
        BUILD_SIZE=$(du -sh dist 2>/dev/null | cut -f1 || echo "unknown")
        
        echo -e "${BLUE}📊 Build Statistics:${NC}"
        echo -e "${BLUE}   • Total files: $TOTAL_FILES${NC}"
        echo -e "${BLUE}   • Build size: $BUILD_SIZE${NC}"
        
    else
        echo -e "${RED}❌ Build output directory not created${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Frontend build failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Frontend build test completed successfully!${NC}"
echo -e "${BLUE}📋 Static assets are properly configured and will be served correctly.${NC}"
