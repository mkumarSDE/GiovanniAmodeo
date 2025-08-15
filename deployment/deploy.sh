#!/bin/bash

# Giovanni Amodeo Separated Architecture Deployment Script
# This script deploys both frontend and backend services to Ubuntu EC2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/var/www/giovanni-amodeo"
BACKUP_DIR="/var/backups/giovanni-amodeo"
FRONTEND_PORT=80
BACKEND_PORT=3001

echo -e "${BLUE}🚀 Deploying Giovanni Amodeo Separated Architecture${NC}"

# Function to check if running as correct user
check_user() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}❌ Please don't run this script as root${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Running as user: $(whoami)${NC}"
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo -e "${BLUE}Detected OS: $OS $VER${NC}"
}

# Function to install system dependencies
install_dependencies() {
    echo -e "${YELLOW}📦 Installing system dependencies...${NC}"
    
    # Update system
    sudo apt update && sudo apt upgrade -y
    
    # Install Node.js 18.x
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Install PM2
    if ! command -v pm2 >/dev/null 2>&1; then
        echo -e "${BLUE}Installing PM2...${NC}"
        sudo npm install -g pm2
    fi
    
    # Install Nginx
    if ! command -v nginx >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Nginx...${NC}"
        sudo apt-get install -y nginx
    fi
    
    # Install additional tools
    sudo apt-get install -y git curl wget unzip vim tree jq htop
    
    echo -e "${GREEN}✅ System dependencies installed${NC}"
}

# Function to setup firewall
setup_firewall() {
    echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
    
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable
        sudo ufw allow ssh
        sudo ufw allow http
        sudo ufw allow https
        sudo ufw allow $BACKEND_PORT/tcp
        echo -e "${GREEN}✅ UFW firewall configured${NC}"
    else
        echo -e "${YELLOW}⚠️  UFW not available${NC}"
    fi
}

# Function to create backup
create_backup() {
    if [ -d "$APP_DIR" ]; then
        echo -e "${YELLOW}📦 Creating backup...${NC}"
        
        sudo mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        sudo cp -r "$APP_DIR" "$BACKUP_DIR/backup_$TIMESTAMP"
        
        # Keep only last 5 backups
        sudo find "$BACKUP_DIR" -name "backup_*" -type d | sort -r | tail -n +6 | sudo xargs rm -rf
        
        echo -e "${GREEN}✅ Backup created: backup_$TIMESTAMP${NC}"
    fi
}

# Function to setup application directory
setup_app_directory() {
    echo -e "${YELLOW}📁 Setting up application directory...${NC}"
    
    # Create application directory
    sudo mkdir -p "$APP_DIR"
    sudo chown -R $USER:$USER "$APP_DIR"
    
    # Create logs directory
    mkdir -p "$APP_DIR/deployment/logs"
    
    echo -e "${GREEN}✅ Application directory ready${NC}"
}

# Function to clone or update repository
update_code() {
    echo -e "${YELLOW}📥 Updating application code...${NC}"
    
    if [ ! -d "$APP_DIR/.git" ]; then
        echo -e "${BLUE}Cloning repository...${NC}"
        echo -e "${YELLOW}Please provide your repository URL:${NC}"
        read -p "Repository URL: " REPO_URL
        
        if [ -n "$REPO_URL" ]; then
            git clone "$REPO_URL" "$APP_DIR"
        else
            echo -e "${YELLOW}⚠️  No repository URL provided. Copying local files...${NC}"
            # Copy current directory structure
            cp -r ../backend "$APP_DIR/"
            cp -r ../frontend "$APP_DIR/"
            cp -r . "$APP_DIR/deployment/"
        fi
    else
        echo -e "${BLUE}Pulling latest changes...${NC}"
        cd "$APP_DIR"
        git fetch origin
        git reset --hard origin/main
    fi
    
    echo -e "${GREEN}✅ Code updated${NC}"
}

# Function to build backend
build_backend() {
    echo -e "${YELLOW}🔧 Building backend...${NC}"
    
    cd "$APP_DIR/backend"
    
    # Install dependencies
    if [ -f "package-lock.json" ]; then
        echo -e "${BLUE}Found existing package-lock.json, checking sync...${NC}"
        # Try npm ci first, if it fails due to sync issues, regenerate lock file
        if ! npm ci --omit=dev 2>/dev/null; then
            echo -e "${YELLOW}⚠️  package-lock.json out of sync, regenerating...${NC}"
            rm -f package-lock.json
            npm install --omit=dev
            echo -e "${BLUE}Regenerated package-lock.json${NC}"
        else
            echo -e "${GREEN}✅ Used existing package-lock.json${NC}"
        fi
    else
        echo -e "${BLUE}No package-lock.json found, using npm install${NC}"
        npm install --omit=dev
        echo -e "${BLUE}Generated package-lock.json for future deployments${NC}"
    fi
    
    # Create environment file
    if [ ! -f ".env" ]; then
        if [ -f "env.example" ]; then
            cp env.example .env
            echo -e "${YELLOW}⚠️  Created .env from template - please update with your configuration${NC}"
        else
            # Create basic .env file
            cat > .env << EOF
NODE_ENV=production
PORT=3001
MONGODB_URI=mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
DB_NAME=giovanni
CORS_ORIGINS=http://localhost:4321,http://localhost:3000
EOF
            echo -e "${GREEN}✅ Created basic .env file${NC}"
        fi
    fi
    
    echo -e "${GREEN}✅ Backend built${NC}"
}

# Function to build frontend
build_frontend() {
    echo -e "${YELLOW}🎨 Building frontend...${NC}"
    
    cd "$APP_DIR/frontend"
    
    # Install dependencies
    if [ -f "package-lock.json" ]; then
        echo -e "${BLUE}Found existing package-lock.json, checking sync...${NC}"
        # Try npm ci first, if it fails due to sync issues, regenerate lock file
        if ! npm ci 2>/dev/null; then
            echo -e "${YELLOW}⚠️  package-lock.json out of sync, regenerating...${NC}"
            rm -f package-lock.json
            npm install
            echo -e "${BLUE}Regenerated package-lock.json${NC}"
        else
            echo -e "${GREEN}✅ Used existing package-lock.json${NC}"
        fi
    else
        echo -e "${BLUE}No package-lock.json found, using npm install${NC}"
        npm install
        echo -e "${BLUE}Generated package-lock.json for future deployments${NC}"
    fi
    
    # Set API URL for production
    export API_URL="http://localhost:$BACKEND_PORT"
    
    # Build static site
    npm run build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Frontend built successfully${NC}"
        
        # Verify build output
        if [ -d "dist" ]; then
            echo -e "${GREEN}✅ Frontend dist directory found${NC}"
        else
            echo -e "${RED}❌ Frontend build failed - no dist directory${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Frontend build failed${NC}"
        exit 1
    fi
}

# Function to setup PM2 startup
setup_pm2_startup() {
    echo -e "${YELLOW}🔧 Configuring PM2 startup...${NC}"
    
    # Configure PM2 startup
    STARTUP_CMD=$(pm2 startup systemd -u $USER --hp $HOME | tail -n 1)
    if [[ $STARTUP_CMD == sudo* ]]; then
        echo -e "${BLUE}Executing: $STARTUP_CMD${NC}"
        eval "$STARTUP_CMD"
        echo -e "${GREEN}✅ PM2 startup configured${NC}"
    fi
}

# Function to start backend service
start_backend() {
    echo -e "${YELLOW}🚀 Starting backend service...${NC}"
    
    cd "$APP_DIR/deployment"
    
    # Stop existing PM2 processes
    pm2 stop ecosystem.config.js 2>/dev/null || true
    pm2 delete ecosystem.config.js 2>/dev/null || true
    
    # Start backend with PM2
    pm2 start ecosystem.config.js --env production
    
    # Save PM2 configuration
    pm2 save
    
    echo -e "${GREEN}✅ Backend service started${NC}"
}

# Function to configure nginx
configure_nginx() {
    echo -e "${YELLOW}🌐 Configuring Nginx...${NC}"
    
    # Copy Nginx configuration
    sudo cp "$APP_DIR/deployment/nginx.conf" /etc/nginx/sites-available/giovanni-amodeo
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/giovanni-amodeo /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test configuration
    if sudo nginx -t; then
        # Enable and start Nginx
        sudo systemctl enable nginx
        sudo systemctl reload nginx
        echo -e "${GREEN}✅ Nginx configured and reloaded${NC}"
    else
        echo -e "${RED}❌ Nginx configuration error${NC}"
        exit 1
    fi
}

# Function to wait for services
wait_for_services() {
    echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
    
    # Wait for backend
    for i in {1..30}; do
        if curl -s http://localhost:$BACKEND_PORT/api/health >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Backend is ready${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # Wait for frontend
    for i in {1..15}; do
        if curl -s http://localhost/ >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Frontend is ready${NC}"
            break
        fi
        echo -n "."
        sleep 1
    done
}

# Function to run health checks
health_check() {
    echo -e "${YELLOW}🔍 Running health checks...${NC}"
    
    # Check PM2 status
    pm2 status
    
    # Check backend health
    echo -e "${BLUE}Backend health check:${NC}"
    if curl -s http://localhost:$BACKEND_PORT/api/health | jq . 2>/dev/null; then
        echo -e "${GREEN}✅ Backend health check passed${NC}"
    else
        echo -e "${RED}❌ Backend health check failed${NC}"
        pm2 logs --lines 10
    fi
    
    # Check frontend
    echo -e "${BLUE}Frontend check:${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Frontend is accessible (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${RED}❌ Frontend check failed (HTTP $HTTP_CODE)${NC}"
    fi
    
    # Check Nginx status
    if sudo systemctl is-active nginx >/dev/null; then
        echo -e "${GREEN}✅ Nginx is running${NC}"
    else
        echo -e "${RED}❌ Nginx is not running${NC}"
    fi
}

# Function to get server information
get_server_info() {
    echo -e "${YELLOW}🌐 Server information...${NC}"
    
    # Get public IP
    PUBLIC_IP=$(curl -s -m 5 ifconfig.me 2>/dev/null || curl -s -m 5 ipinfo.io/ip 2>/dev/null || echo "Unable to detect")
    
    echo -e "${BLUE}Public IP: $PUBLIC_IP${NC}"
    
    if [ "$PUBLIC_IP" != "Unable to detect" ]; then
        echo -e "${GREEN}🌍 Your application is accessible at:${NC}"
        echo -e "${GREEN}   • Frontend: http://$PUBLIC_IP/${NC}"
        echo -e "${GREEN}   • Backend API: http://$PUBLIC_IP/api/health${NC}"
        echo -e "${GREEN}   • API Docs: http://$PUBLIC_IP/api/docs${NC}"
        echo -e "${GREEN}   • Admin: http://$PUBLIC_IP/admin${NC}"
    fi
}

# Function to display summary
display_summary() {
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${BLUE}📋 Architecture Summary:${NC}"
    echo -e "${BLUE}   • Backend: Node.js Express API (Port $BACKEND_PORT)${NC}"
    echo -e "${BLUE}   • Frontend: Static Astro site (Port $FRONTEND_PORT)${NC}"
    echo -e "${BLUE}   • Database: MongoDB Atlas${NC}"
    echo -e "${BLUE}   • Reverse Proxy: Nginx${NC}"
    echo -e "${BLUE}   • Process Manager: PM2${NC}"
    echo ""
    echo -e "${YELLOW}📚 Management commands:${NC}"
    echo -e "${YELLOW}   • Backend logs: pm2 logs giovanni-backend${NC}"
    echo -e "${YELLOW}   • Restart backend: pm2 restart giovanni-backend${NC}"
    echo -e "${YELLOW}   • Nginx logs: sudo tail -f /var/log/nginx/giovanni-amodeo.access.log${NC}"
    echo -e "${YELLOW}   • Reload Nginx: sudo systemctl reload nginx${NC}"
}

# Function to cleanup old files
cleanup_old_files() {
    echo -e "${YELLOW}🧹 Cleaning up old files...${NC}"
    
    # Remove old AWS deployment files
    rm -rf "$APP_DIR/aws-ec2-deployment" 2>/dev/null || true
    
    # Remove old monolithic files
    rm -f "$APP_DIR/src" 2>/dev/null || true
    rm -f "$APP_DIR/astro.config.mjs" 2>/dev/null || true
    rm -f "$APP_DIR/package.json" 2>/dev/null || true
    rm -f "$APP_DIR/package-lock.json" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main execution
main() {
    case "${1:-deploy}" in
        "deploy")
            echo -e "${BLUE}🚀 Starting full deployment...${NC}"
            check_user
            detect_os
            install_dependencies
            setup_firewall
            create_backup
            setup_app_directory
            update_code
            build_backend
            build_frontend
            setup_pm2_startup
            start_backend
            configure_nginx
            wait_for_services
            health_check
            cleanup_old_files
            get_server_info
            display_summary
            ;;
        "backend")
            echo -e "${BLUE}🔧 Deploying backend only...${NC}"
            build_backend
            start_backend
            health_check
            ;;
        "frontend")
            echo -e "${BLUE}🎨 Deploying frontend only...${NC}"
            build_frontend
            configure_nginx
            health_check
            ;;
        "health")
            health_check
            ;;
        "logs")
            pm2 logs giovanni-backend --lines 20
            ;;
        "status")
            pm2 status
            sudo systemctl status nginx
            ;;
        "info")
            get_server_info
            ;;
        "help")
            echo -e "${BLUE}Usage: $0 [COMMAND]${NC}"
            echo ""
            echo -e "${BLUE}Commands:${NC}"
            echo -e "  deploy     - Full deployment (default)"
            echo -e "  backend    - Deploy backend only"
            echo -e "  frontend   - Deploy frontend only"
            echo -e "  health     - Run health checks"
            echo -e "  logs       - Show backend logs"
            echo -e "  status     - Show services status"
            echo -e "  info       - Show server information"
            echo -e "  help       - Show this help"
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo -e "${BLUE}Run: $0 help${NC}"
            exit 1
            ;;
    esac
}

# Handle Ctrl+C
trap 'echo -e "\n${YELLOW}🛑 Deployment interrupted${NC}"; exit 1' INT

# Run main function
main "$@"
