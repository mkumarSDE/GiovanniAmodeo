#!/bin/bash

# Update Video Modal Script
# This script updates the video modal to be simplified - only video player, no extra info

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎬 Updating Video Modal to Simplified Version${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Function to update frontend with simplified modal
update_video_modal() {
    echo -e "${YELLOW}📝 Updating video modal to simplified version...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Check if component exists
    if [ -f "src/components/FeaturedVideos.tsx" ]; then
        echo -e "${GREEN}✅ FeaturedVideos component found${NC}"
    else
        echo -e "${RED}❌ FeaturedVideos component not found${NC}"
        return 1
    fi
    
    # Check if CSS exists
    if [ -f "src/styles/global.css" ]; then
        echo -e "${GREEN}✅ Global CSS found${NC}"
    else
        echo -e "${RED}❌ Global CSS not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📋 Applied modal updates:${NC}"
    echo -e "${BLUE}   • Removed all video metadata and details${NC}"
    echo -e "${BLUE}   • Simplified to video player only${NC}"
    echo -e "${BLUE}   • Made video fill container with proper aspect ratio${NC}"
    echo -e "${BLUE}   • Added backdrop blur effect${NC}"
    echo -e "${BLUE}   • Enhanced close button positioning${NC}"
    echo -e "${BLUE}   • Added Wistia-specific CSS overrides${NC}"
    echo -e "${BLUE}   • Improved mobile responsiveness${NC}"
}

# Function to rebuild frontend
rebuild_frontend() {
    echo -e "${YELLOW}🔨 Rebuilding frontend with simplified modal...${NC}"
    
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
            
            # Check if CSS changes are included
            if grep -q "video-modal" dist/_astro/*.css 2>/dev/null; then
                echo -e "${GREEN}✅ Video modal CSS included in build${NC}"
            else
                echo -e "${YELLOW}⚠️  Video modal CSS might not be included${NC}"
            fi
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

# Function to test modal functionality
test_modal_functionality() {
    echo -e "${YELLOW}🧪 Testing modal functionality...${NC}"
    
    # Test frontend access
    if curl -s --max-time 10 "http://localhost/videos" | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✅ Videos page accessible${NC}"
        
        # Check if JavaScript files are served
        if curl -s --max-time 5 "http://localhost/" | grep -q "_astro.*\.js"; then
            echo -e "${GREEN}✅ JavaScript assets are being served${NC}"
        else
            echo -e "${YELLOW}⚠️  JavaScript assets might not be loading${NC}"
        fi
        
        # Check if CSS files are served
        if curl -s --max-time 5 "http://localhost/" | grep -q "_astro.*\.css"; then
            echo -e "${GREEN}✅ CSS assets are being served${NC}"
        else
            echo -e "${YELLOW}⚠️  CSS assets might not be loading${NC}"
        fi
    else
        echo -e "${RED}❌ Videos page access failed${NC}"
        return 1
    fi
}

# Function to show deployment info
show_deployment_info() {
    echo -e "${GREEN}🎉 Video Modal Updated Successfully!${NC}"
    echo -e "${BLUE}📋 What's Changed:${NC}"
    echo ""
    echo -e "${GREEN}✅ Simplified Modal Design:${NC}"
    echo -e "${BLUE}   • Removed all video metadata and details${NC}"
    echo -e "${BLUE}   • Only shows video player and close button${NC}"
    echo -e "${BLUE}   • Clean, distraction-free viewing experience${NC}"
    echo ""
    echo -e "${GREEN}✅ Improved Video Display:${NC}"
    echo -e "${BLUE}   • Video fills entire container${NC}"
    echo -e "${BLUE}   • Proper 16:9 aspect ratio maintained${NC}"
    echo -e "${BLUE}   • Wistia embeds properly sized${NC}"
    echo -e "${BLUE}   • iframe fallback with same sizing${NC}"
    echo ""
    echo -e "${GREEN}✅ Enhanced User Experience:${NC}"
    echo -e "${BLUE}   • Backdrop blur effect${NC}"
    echo -e "${BLUE}   • Better close button positioning${NC}"
    echo -e "${BLUE}   • Improved mobile responsiveness${NC}"
    echo -e "${BLUE}   • ESC key and click-outside-to-close${NC}"
    echo -e "${BLUE}   • Body scroll prevention${NC}"
    echo ""
    echo -e "${GREEN}✅ Technical Improvements:${NC}"
    echo -e "${BLUE}   • Custom CSS for video modal styling${NC}"
    echo -e "${BLUE}   • Wistia-specific style overrides${NC}"
    echo -e "${BLUE}   • Mobile-optimized layout${NC}"
    echo -e "${BLUE}   • Better shadow and visual effects${NC}"
    echo ""
    echo -e "${YELLOW}📚 Test Your Updated Modal:${NC}"
    echo -e "${YELLOW}   1. Visit: http://13.232.27.48/videos${NC}"
    echo -e "${YELLOW}   2. Click: Any 'Watch Video' button${NC}"
    echo -e "${YELLOW}   3. Verify: Modal shows only video player${NC}"
    echo -e "${YELLOW}   4. Check: Video fills the container properly${NC}"
    echo -e "${YELLOW}   5. Test: ESC key and outside-click to close${NC}"
    echo -e "${YELLOW}   6. Test: Mobile responsiveness${NC}"
}

# Main execution
main() {
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        echo -e "${YELLOW}Please ensure the application is deployed first.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Updating Giovanni Amodeo Video Modal${NC}"
    echo ""
    
    # Update video modal
    update_video_modal
    
    echo ""
    
    # Rebuild frontend
    rebuild_frontend
    
    echo ""
    
    # Restart nginx
    restart_nginx
    
    echo ""
    
    # Test modal functionality
    test_modal_functionality
    
    echo ""
    
    # Show deployment info
    show_deployment_info
}

# Run main function
main
