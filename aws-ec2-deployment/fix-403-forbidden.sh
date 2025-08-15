#!/bin/bash

# Fix 403 Forbidden Nginx Error Script
# This script diagnoses and fixes common causes of 403 Forbidden errors

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing 403 Forbidden Nginx Error${NC}"

APP_DIR="/var/www/giovanni-amodeo"

# Function to check file permissions
check_permissions() {
    echo -e "${YELLOW}📁 Checking file permissions...${NC}"
    
    # Check if app directory exists
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
        return 1
    fi
    
    # Check directory permissions
    echo -e "${BLUE}Directory permissions:${NC}"
    ls -la /var/www/ | grep giovanni-amodeo
    
    # Check dist directory permissions
    if [ -d "$APP_DIR/dist" ]; then
        echo -e "${BLUE}Dist directory permissions:${NC}"
        ls -la "$APP_DIR/dist"
    else
        echo -e "${RED}❌ Dist directory not found${NC}"
        return 1
    fi
    
    # Check nginx user
    echo -e "${BLUE}Nginx user:${NC}"
    ps aux | grep nginx | head -2
}

# Function to fix directory permissions
fix_permissions() {
    echo -e "${YELLOW}🔧 Fixing directory permissions...${NC}"
    
    # Get nginx user
    NGINX_USER=$(ps aux | grep nginx | grep -v root | head -1 | awk '{print $1}')
    if [ -z "$NGINX_USER" ]; then
        # Try common nginx users
        if id www-data >/dev/null 2>&1; then
            NGINX_USER="www-data"
        elif id nginx >/dev/null 2>&1; then
            NGINX_USER="nginx"
        else
            NGINX_USER="nginx"
        fi
    fi
    
    echo -e "${BLUE}Using nginx user: $NGINX_USER${NC}"
    
    # Fix ownership
    echo -e "${BLUE}Setting ownership...${NC}"
    sudo chown -R $NGINX_USER:$NGINX_USER "$APP_DIR/dist" 2>/dev/null || true
    sudo chown -R $USER:$NGINX_USER "$APP_DIR"
    
    # Fix permissions
    echo -e "${BLUE}Setting permissions...${NC}"
    sudo chmod -R 755 "$APP_DIR"
    sudo chmod -R 644 "$APP_DIR/dist"
    sudo find "$APP_DIR/dist" -type d -exec chmod 755 {} \;
    
    # Make sure parent directories are accessible
    sudo chmod 755 /var
    sudo chmod 755 /var/www
    sudo chmod 755 "$APP_DIR"
    
    echo -e "${GREEN}✅ Permissions fixed${NC}"
}

# Function to check nginx configuration
check_nginx_config() {
    echo -e "${YELLOW}🔍 Checking Nginx configuration...${NC}"
    
    # Test nginx configuration
    if sudo nginx -t; then
        echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
    else
        echo -e "${RED}❌ Nginx configuration has errors${NC}"
        return 1
    fi
    
    # Check if our site is enabled
    if [ -f "/etc/nginx/sites-enabled/giovanni-amodeo" ]; then
        echo -e "${GREEN}✅ Site is enabled (Ubuntu/Debian)${NC}"
    elif [ -f "/etc/nginx/conf.d/giovanni-amodeo.conf" ]; then
        echo -e "${GREEN}✅ Site is configured (RHEL/CentOS)${NC}"
    else
        echo -e "${RED}❌ Site configuration not found${NC}"
        return 1
    fi
}

# Function to create a simple nginx configuration
create_simple_nginx_config() {
    echo -e "${YELLOW}🔧 Creating simple Nginx configuration...${NC}"
    
    # Determine nginx config directory
    if [ -d "/etc/nginx/sites-available" ]; then
        CONFIG_DIR="/etc/nginx/sites-available"
        ENABLED_DIR="/etc/nginx/sites-enabled"
        STYLE="ubuntu"
    else
        CONFIG_DIR="/etc/nginx/conf.d"
        ENABLED_DIR=""
        STYLE="rhel"
    fi
    
    # Create simple configuration
    sudo tee "$CONFIG_DIR/giovanni-amodeo.conf" > /dev/null << EOF
# Simple Nginx configuration for Giovanni Amodeo Project
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Root directory
    root $APP_DIR/dist/client;
    index index.html;
    
    # Logging
    access_log /var/log/nginx/giovanni-amodeo.access.log;
    error_log /var/log/nginx/giovanni-amodeo.error.log;
    
    # Try static files first, then proxy to app
    location / {
        try_files \$uri \$uri/ @proxy;
    }
    
    # API routes - proxy to Node.js app
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Health check
    location /health {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        access_log off;
    }
    
    # Proxy fallback
    location @proxy {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Static assets with caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri @proxy;
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF
    
    if [ "$STYLE" = "ubuntu" ]; then
        # Enable site for Ubuntu/Debian
        sudo ln -sf "$CONFIG_DIR/giovanni-amodeo.conf" "$ENABLED_DIR/"
        sudo rm -f "$ENABLED_DIR/default"
    fi
    
    echo -e "${GREEN}✅ Simple configuration created${NC}"
}

# Function to check application status
check_application() {
    echo -e "${YELLOW}🔍 Checking application status...${NC}"
    
    # Check if app is running on port 3000
    if netstat -tlnp 2>/dev/null | grep :3000; then
        echo -e "${GREEN}✅ Application is running on port 3000${NC}"
    else
        echo -e "${RED}❌ No application running on port 3000${NC}"
        
        # Try to start the application
        echo -e "${BLUE}Attempting to start application...${NC}"
        if [ -f "$APP_DIR/aws-ec2-deployment/ecosystem.config.js" ]; then
            cd "$APP_DIR/aws-ec2-deployment"
            pm2 start ecosystem.config.js --env production 2>/dev/null || true
            sleep 3
            
            if netstat -tlnp 2>/dev/null | grep :3000; then
                echo -e "${GREEN}✅ Application started successfully${NC}"
            else
                echo -e "${RED}❌ Failed to start application${NC}"
                pm2 logs --lines 10 2>/dev/null || true
            fi
        fi
    fi
}

# Function to check SELinux (if applicable)
check_selinux() {
    echo -e "${YELLOW}🔍 Checking SELinux...${NC}"
    
    if command -v getenforce >/dev/null 2>&1; then
        SELINUX_STATUS=$(getenforce 2>/dev/null || echo "Unknown")
        echo -e "${BLUE}SELinux status: $SELINUX_STATUS${NC}"
        
        if [ "$SELINUX_STATUS" = "Enforcing" ]; then
            echo -e "${YELLOW}⚠️  SELinux is enforcing - this might cause 403 errors${NC}"
            echo -e "${BLUE}Setting SELinux contexts...${NC}"
            
            # Set proper SELinux contexts
            sudo setsebool -P httpd_can_network_connect 1 2>/dev/null || true
            sudo semanage fcontext -a -t httpd_exec_t "$APP_DIR/dist(/.*)?" 2>/dev/null || true
            sudo restorecon -Rv "$APP_DIR/dist" 2>/dev/null || true
            
            echo -e "${GREEN}✅ SELinux contexts updated${NC}"
        fi
    else
        echo -e "${BLUE}SELinux not found (likely Ubuntu/Debian)${NC}"
    fi
}

# Function to test and fix
test_and_fix() {
    echo -e "${YELLOW}🧪 Testing access...${NC}"
    
    # Test direct access
    echo -e "${BLUE}Testing localhost access:${NC}"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✅ Localhost access works${NC}"
    else
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ || echo "000")
        echo -e "${RED}❌ Localhost access failed (HTTP $HTTP_CODE)${NC}"
    fi
    
    # Check nginx error logs
    echo -e "${BLUE}Recent Nginx error logs:${NC}"
    sudo tail -n 10 /var/log/nginx/error.log 2>/dev/null || echo "No error logs found"
}

# Function to show diagnosis summary
show_diagnosis() {
    echo -e "${BLUE}📋 403 Forbidden Diagnosis Summary:${NC}"
    echo ""
    echo -e "${BLUE}Common causes of 403 Forbidden:${NC}"
    echo -e "  1. ❌ Wrong file permissions"
    echo -e "  2. ❌ Nginx user can't access files"
    echo -e "  3. ❌ Missing index file"
    echo -e "  4. ❌ Incorrect nginx configuration"
    echo -e "  5. ❌ SELinux blocking access"
    echo -e "  6. ❌ Application not running"
    echo ""
    echo -e "${BLUE}What this script fixes:${NC}"
    echo -e "  ✅ Sets correct file permissions (755/644)"
    echo -e "  ✅ Changes ownership to nginx user"
    echo -e "  ✅ Creates working nginx configuration"
    echo -e "  ✅ Starts application if needed"
    echo -e "  ✅ Configures SELinux contexts"
    echo -e "  ✅ Enables proper directory access"
}

# Main execution
main() {
    case "${1:-fix}" in
        "check"|"diagnose")
            check_permissions
            check_nginx_config
            check_application
            check_selinux
            test_and_fix
            show_diagnosis
            ;;
        "fix"|"repair")
            echo -e "${BLUE}🔧 Running complete 403 fix...${NC}"
            fix_permissions
            create_simple_nginx_config
            check_application
            check_selinux
            
            # Test nginx configuration
            if sudo nginx -t; then
                sudo systemctl reload nginx
                echo -e "${GREEN}✅ Nginx reloaded${NC}"
            else
                echo -e "${RED}❌ Nginx configuration error${NC}"
                exit 1
            fi
            
            sleep 2
            test_and_fix
            ;;
        "permissions")
            fix_permissions
            ;;
        "config")
            create_simple_nginx_config
            sudo nginx -t && sudo systemctl reload nginx
            ;;
        "logs")
            echo -e "${BLUE}Nginx error logs:${NC}"
            sudo tail -n 20 /var/log/nginx/error.log 2>/dev/null || echo "No error logs"
            echo ""
            echo -e "${BLUE}Nginx access logs:${NC}"
            sudo tail -n 10 /var/log/nginx/access.log 2>/dev/null || echo "No access logs"
            ;;
        "help")
            echo -e "${BLUE}Usage: $0 [COMMAND]${NC}"
            echo ""
            echo -e "${BLUE}Commands:${NC}"
            echo -e "  fix        - Fix all common 403 issues (default)"
            echo -e "  check      - Diagnose 403 issues"
            echo -e "  permissions- Fix file permissions only"
            echo -e "  config     - Create new nginx configuration"
            echo -e "  logs       - Show nginx logs"
            echo -e "  help       - Show this help"
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
