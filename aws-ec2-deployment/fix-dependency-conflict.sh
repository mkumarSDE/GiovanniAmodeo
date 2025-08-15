#!/bin/bash

# Fix script for Astro dependency conflicts
# Run this on your EC2 server to resolve version conflicts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing Astro Dependency Conflicts${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Check if we're in the right directory
if [ ! -f "$APP_DIR/package.json" ]; then
    echo -e "${RED}❌ Application directory not found at $APP_DIR${NC}"
    exit 1
fi

cd "$APP_DIR"

echo -e "${YELLOW}📦 Checking current Astro version...${NC}"

# Get current Astro version
ASTRO_VERSION=$(npm list astro --depth=0 2>/dev/null | grep astro@ | sed 's/.*astro@//' | sed 's/ .*//')
echo -e "${BLUE}Current Astro version: $ASTRO_VERSION${NC}"

echo -e "${YELLOW}🧹 Cleaning up node_modules and package-lock...${NC}"

# Clean existing installation
rm -rf node_modules/
rm -f package-lock.json

echo -e "${YELLOW}📝 Updating package.json with compatible versions...${NC}"

# Create a new package.json with compatible versions
cat > package.json << 'EOF'
{
  "name": "giovanni-amodeo",
  "type": "module",
  "version": "0.0.1",
  "scripts": {
    "dev": "astro dev",
    "start": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "astro": "astro",
    "migrate": "node migrate-videos.js"
  },
  "dependencies": {
    "@astrojs/check": "^0.9.4",
    "@astrojs/node": "^8.3.4",
    "@astrojs/react": "^3.6.2",
    "@astrojs/tailwind": "^5.1.1",
    "astro": "^4.16.18",
    "mongodb": "^6.3.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "tailwindcss": "^3.4.16",
    "typescript": "^5.6.3"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1"
  }
}
EOF

echo -e "${YELLOW}🔧 Updating Astro configuration...${NC}"

# Update astro.config.mjs for Astro v4
cat > astro.config.mjs << 'EOF'
// @ts-check
import { defineConfig } from 'astro/config';
import node from '@astrojs/node';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), tailwind()],
  output: 'server',
  adapter: node({
    mode: 'standalone'
  }),

  vite: {
    plugins: []
  }
});
EOF

echo -e "${YELLOW}📦 Installing dependencies with legacy peer deps...${NC}"

# Install with legacy peer deps to resolve conflicts
npm install --legacy-peer-deps

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ npm install failed${NC}"
    echo -e "${YELLOW}Trying with --force flag...${NC}"
    npm install --force
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Both install methods failed${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Dependencies installed successfully${NC}"

echo -e "${YELLOW}🔨 Building application...${NC}"

# Clean previous build
rm -rf dist/

# Build the application
npm run build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Application built successfully${NC}"
    
    # Verify the build output
    if [ -f "dist/server/entry.mjs" ]; then
        echo -e "${GREEN}✅ Server entry point found${NC}"
    else
        echo -e "${RED}❌ Server entry point not found${NC}"
        echo -e "${BLUE}Build output:${NC}"
        ls -la dist/
        exit 1
    fi
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${YELLOW}🔄 Restarting application with PM2...${NC}"

cd aws-ec2-deployment

# Stop existing PM2 processes
pm2 stop ecosystem.config.js 2>/dev/null || true
pm2 delete ecosystem.config.js 2>/dev/null || true

# Start application with new configuration
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
pm2 save

echo -e "${YELLOW}🔍 Running health check...${NC}"

# Wait for application to start
sleep 10

# Check application health
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application is running successfully${NC}"
    pm2 status
else
    echo -e "${RED}❌ Application health check failed${NC}"
    echo -e "${BLUE}PM2 logs:${NC}"
    pm2 logs --lines 20
    
    # Try to check what's running on port 3000
    echo -e "${BLUE}Checking port 3000:${NC}"
    netstat -tlnp | grep :3000 || echo "Nothing running on port 3000"
    
    exit 1
fi

echo -e "${GREEN}🎉 Dependency conflict fix completed successfully!${NC}"
echo -e "${BLUE}Your application is now running with compatible versions${NC}"

# Show final versions
echo -e "${BLUE}📋 Final package versions:${NC}"
npm list astro @astrojs/node --depth=0
