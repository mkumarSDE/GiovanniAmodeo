#!/bin/bash

# Complete EC2 Setup and Deployment Script for Giovanni Amodeo Project
# This script handles everything from setup to deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Complete Giovanni Amodeo EC2 Setup and Deployment${NC}"

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}❌ Please don't run this script as root${NC}"
        exit 1
    fi
}

# Function to get current user
get_user_info() {
    CURRENT_USER=$(whoami)
    USER_HOME=$(eval echo ~$CURRENT_USER)
    echo -e "${BLUE}Current user: $CURRENT_USER${NC}"
    echo -e "${BLUE}Home directory: $USER_HOME${NC}"
}

# Function to update system packages
update_system() {
    echo -e "${YELLOW}📦 Updating system packages...${NC}"
    
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt upgrade -y
    elif command -v yum >/dev/null 2>&1; then
        sudo yum update -y
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf update -y
    fi
    
    echo -e "${GREEN}✅ System packages updated${NC}"
}

# Function to install Node.js
install_nodejs() {
    echo -e "${YELLOW}📦 Installing Node.js 18...${NC}"
    
    if command -v apt >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command -v yum >/dev/null 2>&1; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    elif command -v dnf >/dev/null 2>&1; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo dnf install -y nodejs
    fi
    
    echo -e "${GREEN}✅ Node.js installed: $(node --version)${NC}"
    echo -e "${GREEN}✅ npm installed: $(npm --version)${NC}"
}

# Function to install PM2 and configure startup
install_and_configure_pm2() {
    echo -e "${YELLOW}📦 Installing and configuring PM2...${NC}"
    
    # Install PM2 globally
    sudo npm install -g pm2
    
    # Configure PM2 startup with proper user and path
    echo -e "${YELLOW}🔧 Configuring PM2 startup...${NC}"
    
    # Generate startup script
    PM2_STARTUP_CMD=$(pm2 startup systemd -u $CURRENT_USER --hp $USER_HOME | tail -n 1)
    
    # Execute the startup command
    if [[ $PM2_STARTUP_CMD == sudo* ]]; then
        echo -e "${BLUE}Executing: $PM2_STARTUP_CMD${NC}"
        eval "$PM2_STARTUP_CMD"
        echo -e "${GREEN}✅ PM2 startup configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Manual PM2 startup configuration needed${NC}"
        echo -e "${BLUE}Run: $PM2_STARTUP_CMD${NC}"
    fi
}

# Function to install Nginx
install_nginx() {
    echo -e "${YELLOW}📦 Installing Nginx...${NC}"
    
    if command -v apt >/dev/null 2>&1; then
        sudo apt-get install -y nginx
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y nginx
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y nginx
    fi
    
    # Enable and start Nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    echo -e "${GREEN}✅ Nginx installed and started${NC}"
}

# Function to install additional tools
install_tools() {
    echo -e "${YELLOW}📦 Installing additional tools...${NC}"
    
    if command -v apt >/dev/null 2>&1; then
        sudo apt-get install -y git htop curl wget unzip vim tree jq build-essential
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y git htop curl wget unzip vim tree jq gcc gcc-c++ make
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git htop curl wget unzip vim tree jq gcc gcc-c++ make
    fi
    
    echo -e "${GREEN}✅ Additional tools installed${NC}"
}

# Function to setup firewall
setup_firewall() {
    echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
    
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable
        sudo ufw allow ssh
        sudo ufw allow http
        sudo ufw allow https
        sudo ufw allow 3000/tcp
        echo -e "${GREEN}✅ UFW firewall configured${NC}"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --permanent --add-port=3000/tcp
        sudo firewall-cmd --reload
        echo -e "${GREEN}✅ Firewalld configured${NC}"
    else
        echo -e "${YELLOW}⚠️  No firewall configured - please configure manually${NC}"
    fi
}

# Function to clone repository
clone_repository() {
    echo -e "${YELLOW}📥 Setting up application...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    # Create application directory
    sudo mkdir -p "$APP_DIR"
    sudo chown -R $CURRENT_USER:$CURRENT_USER "$APP_DIR"
    
    # Check if repository exists
    if [ ! -d "$APP_DIR/.git" ]; then
        echo -e "${BLUE}Please provide your repository URL:${NC}"
        read -p "Repository URL: " REPO_URL
        
        if [ -n "$REPO_URL" ]; then
            git clone "$REPO_URL" "$APP_DIR"
        else
            echo -e "${YELLOW}⚠️  No repository URL provided. You'll need to clone manually.${NC}"
            echo -e "${BLUE}Run: git clone YOUR_REPO_URL $APP_DIR${NC}"
        fi
    else
        echo -e "${BLUE}Repository already exists, pulling latest changes...${NC}"
        cd "$APP_DIR"
        git pull origin main || git pull origin master
    fi
    
    echo -e "${GREEN}✅ Application repository ready${NC}"
}

# Function to setup environment
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    # Create environment file
    cat > "$APP_DIR/.env" << EOF
# Production Environment Variables
NODE_ENV=production
PORT=3000

# MongoDB Configuration
MONGODB_URI=mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
DB_NAME=giovanni

# CORS Configuration
CORS_ORIGINS=*

# Application Configuration
LOG_LEVEL=info
EOF
    
    # Create logs directory
    mkdir -p "$APP_DIR/aws-ec2-deployment/logs"
    
    echo -e "${GREEN}✅ Environment configured${NC}"
}

# Function to deploy application
deploy_application() {
    echo -e "${YELLOW}🚀 Deploying application...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found${NC}"
        exit 1
    fi
    
    cd "$APP_DIR"
    
    # Install dependencies
    echo -e "${BLUE}Installing dependencies...${NC}"
    npm ci --production
    
    # Install deployment dependencies
    if [ -d "aws-ec2-deployment" ]; then
        cd aws-ec2-deployment
        npm install
        cd ..
    fi
    
    # Build application
    echo -e "${BLUE}Building application...${NC}"
    npm run build
    
    # Start with PM2
    echo -e "${BLUE}Starting application with PM2...${NC}"
    cd aws-ec2-deployment
    
    # Stop existing processes
    pm2 stop ecosystem.config.js 2>/dev/null || true
    pm2 delete ecosystem.config.js 2>/dev/null || true
    
    # Start application
    pm2 start ecosystem.config.js --env production
    
    # Save PM2 configuration
    pm2 save
    
    echo -e "${GREEN}✅ Application deployed and running${NC}"
}

# Function to configure Nginx
configure_nginx() {
    echo -e "${YELLOW}🌐 Configuring Nginx...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    if [ -f "$APP_DIR/aws-ec2-deployment/nginx.conf" ]; then
        # Copy Nginx configuration
        sudo cp "$APP_DIR/aws-ec2-deployment/nginx.conf" /etc/nginx/sites-available/giovanni-amodeo
        
        # Enable site (Ubuntu/Debian style)
        if [ -d "/etc/nginx/sites-enabled" ]; then
            sudo ln -sf /etc/nginx/sites-available/giovanni-amodeo /etc/nginx/sites-enabled/
            sudo rm -f /etc/nginx/sites-enabled/default
        else
            # RHEL style
            sudo cp "$APP_DIR/aws-ec2-deployment/nginx.conf" /etc/nginx/conf.d/giovanni-amodeo.conf
        fi
        
        # Test configuration
        sudo nginx -t
        
        if [ $? -eq 0 ]; then
            sudo systemctl reload nginx
            echo -e "${GREEN}✅ Nginx configured and reloaded${NC}"
        else
            echo -e "${RED}❌ Nginx configuration error${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Nginx configuration file not found${NC}"
    fi
}

# Function to run health checks
health_check() {
    echo -e "${YELLOW}🔍 Running health checks...${NC}"
    
    # Wait for application to start
    sleep 5
    
    # Check PM2 status
    pm2 status
    
    # Check application health
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Application health check passed${NC}"
    else
        echo -e "${RED}❌ Application health check failed${NC}"
        pm2 logs --lines 20
    fi
    
    # Check Nginx status
    if sudo systemctl is-active nginx > /dev/null; then
        echo -e "${GREEN}✅ Nginx is running${NC}"
    else
        echo -e "${RED}❌ Nginx is not running${NC}"
    fi
}

# Function to display summary
display_summary() {
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${BLUE}📋 Summary:${NC}"
    echo -e "${BLUE}   • User: $CURRENT_USER${NC}"
    echo -e "${BLUE}   • Node.js: $(node --version)${NC}"
    echo -e "${BLUE}   • PM2: Configured with startup${NC}"
    echo -e "${BLUE}   • Nginx: Running${NC}"
    echo -e "${BLUE}   • Application: Running on port 3000${NC}"
    echo ""
    echo -e "${YELLOW}🌐 Access your application:${NC}"
    echo -e "${YELLOW}   • Website: http://$(curl -s ifconfig.me)${NC}"
    echo -e "${YELLOW}   • API: http://$(curl -s ifconfig.me)/api/videos${NC}"
    echo -e "${YELLOW}   • Health: http://$(curl -s ifconfig.me)/health${NC}"
    echo ""
    echo -e "${YELLOW}📚 Useful commands:${NC}"
    echo -e "${YELLOW}   • View logs: pm2 logs${NC}"
    echo -e "${YELLOW}   • Restart: pm2 restart ecosystem.config.js${NC}"
    echo -e "${YELLOW}   • Status: pm2 status${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}🔧 Starting complete setup and deployment...${NC}"
    
    check_root
    get_user_info
    update_system
    install_nodejs
    install_and_configure_pm2
    install_nginx
    install_tools
    setup_firewall
    clone_repository
    setup_environment
    deploy_application
    configure_nginx
    health_check
    display_summary
    
    echo -e "${GREEN}🚀 Complete setup and deployment finished!${NC}"
}

# Run main function
main
