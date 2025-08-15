#!/bin/bash

# Quick fix script for Astro adapter issue
# Run this on your EC2 server to fix the current deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing Astro Adapter Configuration${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Check if we're in the right directory
if [ ! -f "$APP_DIR/package.json" ]; then
    echo -e "${RED}❌ Application directory not found at $APP_DIR${NC}"
    exit 1
fi

cd "$APP_DIR"

echo -e "${YELLOW}📦 Installing Astro Node.js adapter...${NC}"

# Install the Node.js adapter
npm install @astrojs/node

echo -e "${YELLOW}🔧 Updating Astro configuration...${NC}"

# Backup current astro.config.mjs
cp astro.config.mjs astro.config.mjs.backup

# Update astro.config.mjs with Node adapter
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

echo -e "${YELLOW}🔨 Rebuilding application...${NC}"

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
sleep 5

# Check application health
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application is running successfully${NC}"
    pm2 status
else
    echo -e "${RED}❌ Application health check failed${NC}"
    echo -e "${BLUE}PM2 logs:${NC}"
    pm2 logs --lines 10
    exit 1
fi

echo -e "${GREEN}🎉 Astro adapter fix completed successfully!${NC}"
echo -e "${BLUE}Your application is now running with the Node.js adapter${NC}"
