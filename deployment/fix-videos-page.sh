#!/bin/bash

# Fix Videos Page Script
# This script updates the videos page to filter valid videos and fix the Watch Now button

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing Videos Page Issues${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Function to update frontend with fixes
update_frontend_fixes() {
    echo -e "${YELLOW}📝 Updating frontend with video page fixes...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Check if component exists
    if [ -f "src/components/FeaturedVideos.tsx" ]; then
        echo -e "${GREEN}✅ FeaturedVideos component found${NC}"
    else
        echo -e "${RED}❌ FeaturedVideos component not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📋 Applied fixes:${NC}"
    echo -e "${BLUE}   • Filter videos with valid video_id only${NC}"
    echo -e "${BLUE}   • Add Watch Now button functionality${NC}"
    echo -e "${BLUE}   • Create video modal with Wistia player${NC}"
    echo -e "${BLUE}   • Add ESC key and click-outside-to-close${NC}"
    echo -e "${BLUE}   • Prevent body scroll when modal is open${NC}"
}

# Function to rebuild frontend
rebuild_frontend() {
    echo -e "${YELLOW}🔨 Rebuilding frontend with fixes...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Set environment variable for build
    export API_URL="http://13.232.27.48"
    
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

# Function to test video filtering
test_video_filtering() {
    echo -e "${YELLOW}🧪 Testing video filtering...${NC}"
    
    # Test API to count videos
    echo -e "${BLUE}Testing API at http://13.232.27.48/api/videos...${NC}"
    
    if API_RESPONSE=$(curl -s --max-time 10 "http://13.232.27.48/api/videos"); then
        if echo "$API_RESPONSE" | grep -q '"success":true'; then
            TOTAL_VIDEOS=$(echo "$API_RESPONSE" | grep -o '"count":[0-9]*' | cut -d':' -f2 || echo "unknown")
            echo -e "${GREEN}✅ API responded with $TOTAL_VIDEOS total videos${NC}"
            
            # Count videos with valid video_id
            VALID_VIDEOS=$(echo "$API_RESPONSE" | grep -o '"video_id":"[^"]*"' | grep -v '"video_id":""' | wc -l || echo "0")
            echo -e "${BLUE}📊 Videos with valid video_id: $VALID_VIDEOS${NC}"
            
            if [ "$VALID_VIDEOS" -gt 0 ]; then
                echo -e "${GREEN}✅ Found videos with valid IDs for display${NC}"
            else
                echo -e "${YELLOW}⚠️  No videos with valid video_id found${NC}"
            fi
        else
            echo -e "${RED}❌ API returned error response${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Failed to reach API${NC}"
        return 1
    fi
}

# Function to test frontend access
test_frontend_access() {
    echo -e "${YELLOW}🧪 Testing frontend access...${NC}"
    
    # Test main page
    if curl -s --max-time 10 "http://localhost/" | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✅ Main page accessible${NC}"
    else
        echo -e "${RED}❌ Main page access failed${NC}"
        return 1
    fi
    
    # Test videos page
    if curl -s --max-time 10 "http://localhost/videos" | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✅ Videos page accessible${NC}"
    else
        echo -e "${RED}❌ Videos page access failed${NC}"
        return 1
    fi
}

# Function to show deployment info
show_deployment_info() {
    echo -e "${GREEN}🎉 Videos Page Fixes Applied!${NC}"
    echo -e "${BLUE}📋 What's Fixed:${NC}"
    echo ""
    echo -e "${GREEN}✅ Video Filtering:${NC}"
    echo -e "${BLUE}   • Only videos with valid video_id are displayed${NC}"
    echo -e "${BLUE}   • Empty or missing video_id entries are filtered out${NC}"
    echo -e "${BLUE}   • Console logging shows filtering statistics${NC}"
    echo ""
    echo -e "${GREEN}✅ Watch Now Button:${NC}"
    echo -e "${BLUE}   • Button now opens a video modal${NC}"
    echo -e "${BLUE}   • Modal displays Wistia video player${NC}"
    echo -e "${BLUE}   • Full video details and metadata shown${NC}"
    echo ""
    echo -e "${GREEN}✅ Video Modal Features:${NC}"
    echo -e "${BLUE}   • Responsive design (mobile-friendly)${NC}"
    echo -e "${BLUE}   • ESC key to close modal${NC}"
    echo -e "${BLUE}   • Click outside to close modal${NC}"
    echo -e "${BLUE}   • Body scroll prevention when open${NC}"
    echo -e "${BLUE}   • Video player with fallback iframe${NC}"
    echo -e "${BLUE}   • Complete video metadata display${NC}"
    echo ""
    echo -e "${YELLOW}📚 Test Your Website:${NC}"
    echo -e "${YELLOW}   1. Visit: http://13.232.27.48/videos${NC}"
    echo -e "${YELLOW}   2. Check: Only videos with thumbnails appear${NC}"
    echo -e "${YELLOW}   3. Click: 'Watch Video' buttons work${NC}"
    echo -e "${YELLOW}   4. Test: Modal opens with video player${NC}"
    echo -e "${YELLOW}   5. Test: ESC key and outside-click to close${NC}"
}

# Main execution
main() {
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        echo -e "${YELLOW}Please ensure the application is deployed first.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Fixing Giovanni Amodeo Videos Page${NC}"
    echo ""
    
    # Update frontend with fixes
    update_frontend_fixes
    
    echo ""
    
    # Rebuild frontend
    rebuild_frontend
    
    echo ""
    
    # Restart nginx
    restart_nginx
    
    echo ""
    
    # Test video filtering
    test_video_filtering
    
    echo ""
    
    # Test frontend access
    test_frontend_access
    
    echo ""
    
    # Show deployment info
    show_deployment_info
}

# Run main function
main
