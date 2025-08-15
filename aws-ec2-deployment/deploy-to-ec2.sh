#!/bin/bash

# AWS EC2 Deployment Script for Giovanni Amodeo Project
# This script deploys the application to EC2

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
SERVICE_NAME="giovanni-amodeo"

echo -e "${BLUE}🚀 Deploying Giovanni Amodeo Project to EC2${NC}"

# Function to check if running on EC2
check_environment() {
    if [ ! -f /etc/system-release ]; then
        echo -e "${RED}❌ This script is designed for Amazon Linux EC2 instances${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Running on Amazon Linux EC2${NC}"
}

# Function to create backup
create_backup() {
    if [ -d "$APP_DIR" ]; then
        echo -e "${YELLOW}📦 Creating backup...${NC}"
        
        # Create backup directory
        sudo mkdir -p "$BACKUP_DIR"
        
        # Create backup with timestamp
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        sudo cp -r "$APP_DIR" "$BACKUP_DIR/backup_$TIMESTAMP"
        
        # Keep only last 5 backups
        sudo find "$BACKUP_DIR" -name "backup_*" -type d | sort -r | tail -n +6 | sudo xargs rm -rf
        
        echo -e "${GREEN}✅ Backup created: backup_$TIMESTAMP${NC}"
    fi
}

# Function to clone or update repository
update_code() {
    echo -e "${YELLOW}📥 Updating application code...${NC}"
    
    if [ ! -d "$APP_DIR/.git" ]; then
        echo -e "${BLUE}Cloning repository...${NC}"
        sudo rm -rf "$APP_DIR"
        sudo mkdir -p "$APP_DIR"
        sudo chown -R $USER:$USER "$APP_DIR"
        
        # Clone repository (you'll need to set the correct repo URL)
        git clone https://github.com/your-username/giovanni-amodeo.git "$APP_DIR"
    else
        echo -e "${BLUE}Pulling latest changes...${NC}"
        cd "$APP_DIR"
        git fetch origin
        git reset --hard origin/main
    fi
    
    echo -e "${GREEN}✅ Code updated${NC}"
}

# Function to install dependencies
install_dependencies() {
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    
    cd "$APP_DIR"
    
    # Install main project dependencies
    npm ci --production
    
    # Install deployment dependencies
    cd aws-ec2-deployment
    npm install
    
    cd "$APP_DIR"
    
    echo -e "${GREEN}✅ Dependencies installed${NC}"
}

# Function to build application
build_application() {
    echo -e "${YELLOW}🔨 Building application...${NC}"
    
    cd "$APP_DIR"
    
    # Build the Astro application
    npm run build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Application built successfully${NC}"
    else
        echo -e "${RED}❌ Build failed${NC}"
        exit 1
    fi
}

# Function to setup environment
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"
    
    # Copy environment file if it doesn't exist
    if [ ! -f "$APP_DIR/.env" ]; then
        cp "$APP_DIR/aws-ec2-deployment/.env.example" "$APP_DIR/.env" 2>/dev/null || true
    fi
    
    # Create logs directory
    mkdir -p "$APP_DIR/aws-ec2-deployment/logs"
    
    # Set proper permissions
    sudo chown -R $USER:nginx "$APP_DIR"
    sudo chmod -R 755 "$APP_DIR"
    
    echo -e "${GREEN}✅ Environment configured${NC}"
}

# Function to start/restart application with PM2
start_application() {
    echo -e "${YELLOW}🚀 Starting application...${NC}"
    
    cd "$APP_DIR/aws-ec2-deployment"
    
    # Stop existing PM2 processes
    pm2 stop ecosystem.config.js 2>/dev/null || true
    pm2 delete ecosystem.config.js 2>/dev/null || true
    
    # Start application with PM2
    pm2 start ecosystem.config.js --env production
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 startup script (if not already done)
    pm2 startup || true
    
    echo -e "${GREEN}✅ Application started with PM2${NC}"
}

# Function to configure Nginx
configure_nginx() {
    echo -e "${YELLOW}🌐 Configuring Nginx...${NC}"
    
    # Copy Nginx configuration
    sudo cp "$APP_DIR/aws-ec2-deployment/nginx.conf" /etc/nginx/conf.d/giovanni-amodeo.conf
    
    # Test Nginx configuration
    sudo nginx -t
    
    if [ $? -eq 0 ]; then
        # Reload Nginx
        sudo systemctl reload nginx
        echo -e "${GREEN}✅ Nginx configured and reloaded${NC}"
    else
        echo -e "${RED}❌ Nginx configuration error${NC}"
        exit 1
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
        exit 1
    fi
    
    # Check Nginx status
    if sudo systemctl is-active nginx > /dev/null; then
        echo -e "${GREEN}✅ Nginx is running${NC}"
    else
        echo -e "${RED}❌ Nginx is not running${NC}"
        exit 1
    fi
}

# Function to display deployment summary
display_summary() {
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${BLUE}📋 Summary:${NC}"
    echo -e "${BLUE}   • Application: Running on PM2${NC}"
    echo -e "${BLUE}   • Port: 3000${NC}"
    echo -e "${BLUE}   • Nginx: Configured and running${NC}"
    echo -e "${BLUE}   • Health check: http://localhost:3000/health${NC}"
    echo ""
    echo -e "${YELLOW}📚 Useful commands:${NC}"
    echo -e "${YELLOW}   • View logs: pm2 logs${NC}"
    echo -e "${YELLOW}   • Restart app: pm2 restart ecosystem.config.js${NC}"
    echo -e "${YELLOW}   • Stop app: pm2 stop ecosystem.config.js${NC}"
    echo -e "${YELLOW}   • Nginx logs: sudo tail -f /var/log/nginx/error.log${NC}"
    echo -e "${YELLOW}   • Application logs: tail -f $APP_DIR/aws-ec2-deployment/logs/combined.log${NC}"
}

# Function to rollback deployment
rollback() {
    echo -e "${YELLOW}🔄 Rolling back deployment...${NC}"
    
    # Find latest backup
    LATEST_BACKUP=$(sudo find "$BACKUP_DIR" -name "backup_*" -type d | sort -r | head -n 1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        # Stop current application
        pm2 stop ecosystem.config.js 2>/dev/null || true
        
        # Restore from backup
        sudo rm -rf "$APP_DIR"
        sudo cp -r "$LATEST_BACKUP" "$APP_DIR"
        sudo chown -R $USER:nginx "$APP_DIR"
        
        # Restart application
        cd "$APP_DIR/aws-ec2-deployment"
        pm2 start ecosystem.config.js --env production
        
        echo -e "${GREEN}✅ Rollback completed${NC}"
    else
        echo -e "${RED}❌ No backup found for rollback${NC}"
        exit 1
    fi
}

# Main execution
main() {
    case "${1:-deploy}" in
        "deploy")
            echo -e "${BLUE}🚀 Starting deployment...${NC}"
            check_environment
            create_backup
            update_code
            install_dependencies
            build_application
            setup_environment
            start_application
            configure_nginx
            health_check
            display_summary
            ;;
        "rollback")
            rollback
            ;;
        "health")
            health_check
            ;;
        "logs")
            pm2 logs
            ;;
        "status")
            pm2 status
            sudo systemctl status nginx
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo -e "${BLUE}Usage: $0 [deploy|rollback|health|logs|status]${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
