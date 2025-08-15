#!/bin/bash

# Nginx Port 3000 Configuration Script
# This script helps configure Nginx to properly bind and proxy to port 3000

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌐 Configuring Nginx for Port 3000${NC}"

# Function to check if running as root for nginx commands
check_nginx_permissions() {
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}⚠️  This script needs sudo permissions for Nginx configuration${NC}"
        echo "Please run with sudo or ensure your user can run sudo commands"
    fi
}

# Function to check current port bindings
check_port_status() {
    echo -e "${YELLOW}🔍 Checking current port status...${NC}"
    
    # Check what's running on port 3000
    echo -e "${BLUE}Port 3000 status:${NC}"
    if netstat -tlnp 2>/dev/null | grep :3000; then
        echo -e "${GREEN}✅ Something is running on port 3000${NC}"
    else
        echo -e "${RED}❌ Nothing running on port 3000${NC}"
    fi
    
    # Check what's running on port 80
    echo -e "${BLUE}Port 80 status:${NC}"
    if netstat -tlnp 2>/dev/null | grep :80; then
        echo -e "${GREEN}✅ Something is running on port 80${NC}"
    else
        echo -e "${RED}❌ Nothing running on port 80${NC}"
    fi
    
    # Check Nginx status
    echo -e "${BLUE}Nginx status:${NC}"
    if sudo systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Nginx is running${NC}"
    else
        echo -e "${RED}❌ Nginx is not running${NC}"
    fi
}

# Function to test connectivity
test_connectivity() {
    echo -e "${YELLOW}🧪 Testing connectivity...${NC}"
    
    # Test direct connection to port 3000
    echo -e "${BLUE}Testing direct connection to port 3000:${NC}"
    if curl -s -m 5 http://localhost:3000/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Port 3000 is responding${NC}"
        curl -s http://localhost:3000/health | head -c 200
        echo ""
    else
        echo -e "${RED}❌ Port 3000 is not responding${NC}"
    fi
    
    # Test Nginx proxy
    echo -e "${BLUE}Testing Nginx proxy (port 80):${NC}"
    if curl -s -m 5 http://localhost/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Nginx proxy is working${NC}"
        curl -s http://localhost/health | head -c 200
        echo ""
    else
        echo -e "${RED}❌ Nginx proxy is not working${NC}"
    fi
}

# Function to configure Nginx
configure_nginx() {
    echo -e "${YELLOW}🔧 Configuring Nginx...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    # Check if our nginx config exists
    if [ -f "$APP_DIR/aws-ec2-deployment/nginx.conf" ]; then
        echo -e "${BLUE}Found Nginx configuration file${NC}"
        
        # Copy configuration
        if [ -d "/etc/nginx/sites-available" ]; then
            # Ubuntu/Debian style
            echo -e "${BLUE}Configuring for Ubuntu/Debian...${NC}"
            sudo cp "$APP_DIR/aws-ec2-deployment/nginx.conf" /etc/nginx/sites-available/giovanni-amodeo
            sudo ln -sf /etc/nginx/sites-available/giovanni-amodeo /etc/nginx/sites-enabled/
            sudo rm -f /etc/nginx/sites-enabled/default
        else
            # RHEL/CentOS style
            echo -e "${BLUE}Configuring for RHEL/CentOS...${NC}"
            sudo cp "$APP_DIR/aws-ec2-deployment/nginx.conf" /etc/nginx/conf.d/giovanni-amodeo.conf
        fi
        
        # Test configuration
        echo -e "${BLUE}Testing Nginx configuration...${NC}"
        if sudo nginx -t; then
            echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
            
            # Reload Nginx
            sudo systemctl reload nginx
            echo -e "${GREEN}✅ Nginx reloaded${NC}"
        else
            echo -e "${RED}❌ Nginx configuration has errors${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Nginx configuration file not found${NC}"
        return 1
    fi
}

# Function to start application if not running
start_application() {
    echo -e "${YELLOW}🚀 Checking application status...${NC}"
    
    APP_DIR="/var/www/giovanni-amodeo"
    
    if [ -d "$APP_DIR" ]; then
        cd "$APP_DIR"
        
        # Check if PM2 is managing our app
        if pm2 list | grep -q giovanni-amodeo; then
            echo -e "${GREEN}✅ Application is running with PM2${NC}"
            pm2 status giovanni-amodeo
        else
            echo -e "${YELLOW}⚠️  Application not found in PM2${NC}"
            echo -e "${BLUE}Attempting to start application...${NC}"
            
            if [ -f "aws-ec2-deployment/ecosystem.config.js" ]; then
                cd aws-ec2-deployment
                pm2 start ecosystem.config.js --env production
                pm2 save
                echo -e "${GREEN}✅ Application started${NC}"
            else
                echo -e "${RED}❌ PM2 configuration not found${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ Application directory not found${NC}"
    fi
}

# Function to show configuration summary
show_configuration() {
    echo -e "${BLUE}📋 Current Configuration Summary:${NC}"
    echo ""
    echo -e "${BLUE}Nginx Configuration:${NC}"
    echo -e "  • Listens on: Port 80 (HTTP)"
    echo -e "  • Proxies to: 127.0.0.1:3000"
    echo -e "  • Upstream: giovanni_app"
    echo ""
    echo -e "${BLUE}Application:${NC}"
    echo -e "  • Runs on: Port 3000"
    echo -e "  • Managed by: PM2"
    echo -e "  • Entry point: dist/server/entry.mjs"
    echo ""
    echo -e "${BLUE}Access URLs:${NC}"
    echo -e "  • Direct: http://your-server-ip:3000"
    echo -e "  • Via Nginx: http://your-server-ip"
    echo -e "  • API: http://your-server-ip/api/videos"
    echo -e "  • Health: http://your-server-ip/health"
}

# Function to fix common issues
fix_common_issues() {
    echo -e "${YELLOW}🔧 Fixing common issues...${NC}"
    
    # Check if port 3000 is blocked by firewall
    echo -e "${BLUE}Checking firewall for port 3000...${NC}"
    if command -v ufw >/dev/null 2>&1; then
        if sudo ufw status | grep -q "3000"; then
            echo -e "${GREEN}✅ Port 3000 is allowed in UFW${NC}"
        else
            echo -e "${YELLOW}Adding port 3000 to UFW...${NC}"
            sudo ufw allow 3000/tcp
        fi
    elif command -v firewall-cmd >/dev/null 2>&1; then
        if sudo firewall-cmd --list-ports | grep -q "3000"; then
            echo -e "${GREEN}✅ Port 3000 is allowed in firewalld${NC}"
        else
            echo -e "${YELLOW}Adding port 3000 to firewalld...${NC}"
            sudo firewall-cmd --permanent --add-port=3000/tcp
            sudo firewall-cmd --reload
        fi
    fi
    
    # Check if Nginx is enabled and running
    if ! sudo systemctl is-enabled nginx >/dev/null 2>&1; then
        echo -e "${YELLOW}Enabling Nginx service...${NC}"
        sudo systemctl enable nginx
    fi
    
    if ! sudo systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "${YELLOW}Starting Nginx service...${NC}"
        sudo systemctl start nginx
    fi
}

# Main execution
main() {
    case "${1:-status}" in
        "status"|"check")
            check_nginx_permissions
            check_port_status
            test_connectivity
            show_configuration
            ;;
        "configure"|"setup")
            check_nginx_permissions
            configure_nginx
            fix_common_issues
            start_application
            test_connectivity
            show_configuration
            ;;
        "fix")
            check_nginx_permissions
            fix_common_issues
            configure_nginx
            sudo systemctl restart nginx
            test_connectivity
            ;;
        "restart")
            check_nginx_permissions
            sudo systemctl restart nginx
            pm2 restart giovanni-amodeo 2>/dev/null || true
            sleep 3
            test_connectivity
            ;;
        "logs")
            echo -e "${BLUE}Nginx access logs:${NC}"
            sudo tail -n 20 /var/log/nginx/access.log 2>/dev/null || echo "No access logs found"
            echo ""
            echo -e "${BLUE}Nginx error logs:${NC}"
            sudo tail -n 20 /var/log/nginx/error.log 2>/dev/null || echo "No error logs found"
            echo ""
            echo -e "${BLUE}Application logs:${NC}"
            pm2 logs giovanni-amodeo --lines 10 2>/dev/null || echo "No PM2 logs found"
            ;;
        "help")
            echo -e "${BLUE}Usage: $0 [COMMAND]${NC}"
            echo ""
            echo -e "${BLUE}Commands:${NC}"
            echo -e "  status     - Check current port and service status"
            echo -e "  configure  - Set up Nginx configuration"
            echo -e "  fix        - Fix common configuration issues"
            echo -e "  restart    - Restart Nginx and application"
            echo -e "  logs       - Show Nginx and application logs"
            echo -e "  help       - Show this help message"
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo -e "${BLUE}Run: $0 help${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
