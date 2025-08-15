#!/bin/bash

# Verify Deployment Script
# This script properly checks if everything is working after the 403 fix

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verifying Deployment Status${NC}"

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_wait=${3:-30}
    
    echo -e "${YELLOW}⏳ Waiting for $service_name to be ready on port $port...${NC}"
    
    for i in $(seq 1 $max_wait); do
        if netstat -tlnp 2>/dev/null | grep ":$port " >/dev/null; then
            echo -e "${GREEN}✅ $service_name is listening on port $port${NC}"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo -e "${RED}❌ $service_name failed to start on port $port after ${max_wait}s${NC}"
    return 1
}

# Function to test HTTP endpoints
test_endpoints() {
    echo -e "${YELLOW}🧪 Testing HTTP endpoints...${NC}"
    
    # Test direct app connection (port 3000)
    echo -e "${BLUE}Testing direct app connection (port 3000):${NC}"
    if curl -s -m 10 http://localhost:3000/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Direct app connection works${NC}"
        HEALTH_RESPONSE=$(curl -s http://localhost:3000/health)
        echo -e "${BLUE}Health response: $HEALTH_RESPONSE${NC}"
    else
        echo -e "${RED}❌ Direct app connection failed${NC}"
    fi
    
    # Test Nginx proxy (port 80)
    echo -e "${BLUE}Testing Nginx proxy (port 80):${NC}"
    if curl -s -m 10 http://localhost/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Nginx proxy works${NC}"
        PROXY_RESPONSE=$(curl -s http://localhost/health)
        echo -e "${BLUE}Proxy response: $PROXY_RESPONSE${NC}"
    else
        echo -e "${RED}❌ Nginx proxy failed${NC}"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health 2>/dev/null || echo "000")
        echo -e "${BLUE}HTTP Status Code: $HTTP_CODE${NC}"
    fi
    
    # Test API endpoint
    echo -e "${BLUE}Testing API endpoint:${NC}"
    if curl -s -m 10 http://localhost/api/videos >/dev/null 2>&1; then
        echo -e "${GREEN}✅ API endpoint works${NC}"
    else
        echo -e "${RED}❌ API endpoint failed${NC}"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/videos 2>/dev/null || echo "000")
        echo -e "${BLUE}HTTP Status Code: $HTTP_CODE${NC}"
    fi
    
    # Test main page
    echo -e "${BLUE}Testing main page:${NC}"
    if curl -s -m 10 http://localhost/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Main page works${NC}"
    else
        echo -e "${RED}❌ Main page failed${NC}"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
        echo -e "${BLUE}HTTP Status Code: $HTTP_CODE${NC}"
    fi
}

# Function to check services status
check_services() {
    echo -e "${YELLOW}📊 Checking services status...${NC}"
    
    # Check PM2 status
    echo -e "${BLUE}PM2 Status:${NC}"
    pm2 status
    
    # Check Nginx status
    echo -e "${BLUE}Nginx Status:${NC}"
    if sudo systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Nginx is running${NC}"
    else
        echo -e "${RED}❌ Nginx is not running${NC}"
    fi
    
    # Check port bindings
    echo -e "${BLUE}Port Bindings:${NC}"
    echo -e "${BLUE}Port 3000 (App):${NC}"
    netstat -tlnp 2>/dev/null | grep :3000 || echo "Nothing on port 3000"
    
    echo -e "${BLUE}Port 80 (Nginx):${NC}"
    netstat -tlnp 2>/dev/null | grep :80 || echo "Nothing on port 80"
}

# Function to show recent logs
show_logs() {
    echo -e "${YELLOW}📋 Recent logs...${NC}"
    
    # PM2 logs
    echo -e "${BLUE}PM2 Application Logs (last 5 lines):${NC}"
    pm2 logs giovanni-amodeo --lines 5 --nostream 2>/dev/null || echo "No PM2 logs available"
    
    # Nginx error logs
    echo -e "${BLUE}Nginx Error Logs (last 5 lines):${NC}"
    sudo tail -n 5 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx error logs"
    
    # Nginx access logs
    echo -e "${BLUE}Nginx Access Logs (last 3 lines):${NC}"
    sudo tail -n 3 /var/log/nginx/access.log 2>/dev/null || echo "No Nginx access logs"
}

# Function to get server IP
get_server_info() {
    echo -e "${YELLOW}🌐 Server Information...${NC}"
    
    # Get public IP
    PUBLIC_IP=$(curl -s -m 5 ifconfig.me 2>/dev/null || curl -s -m 5 ipinfo.io/ip 2>/dev/null || echo "Unable to detect")
    
    # Get private IP
    PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "Unable to detect")
    
    echo -e "${BLUE}Public IP: $PUBLIC_IP${NC}"
    echo -e "${BLUE}Private IP: $PRIVATE_IP${NC}"
    
    if [ "$PUBLIC_IP" != "Unable to detect" ]; then
        echo -e "${GREEN}🌍 Your application should be accessible at:${NC}"
        echo -e "${GREEN}   • Main Site: http://$PUBLIC_IP/${NC}"
        echo -e "${GREEN}   • API: http://$PUBLIC_IP/api/videos${NC}"
        echo -e "${GREEN}   • Health: http://$PUBLIC_IP/health${NC}"
        echo -e "${GREEN}   • Admin: http://$PUBLIC_IP/admin${NC}"
    fi
}

# Function to fix common issues
quick_fixes() {
    echo -e "${YELLOW}🔧 Applying quick fixes...${NC}"
    
    # Ensure PM2 is saved
    pm2 save >/dev/null 2>&1 || true
    
    # Reload Nginx configuration
    if sudo nginx -t >/dev/null 2>&1; then
        sudo systemctl reload nginx >/dev/null 2>&1
        echo -e "${GREEN}✅ Nginx configuration reloaded${NC}"
    else
        echo -e "${RED}❌ Nginx configuration has errors${NC}"
        sudo nginx -t
    fi
    
    # Wait a moment for services to stabilize
    sleep 3
}

# Main execution
main() {
    case "${1:-verify}" in
        "verify"|"check")
            quick_fixes
            wait_for_service "Application" 3000 15
            wait_for_service "Nginx" 80 10
            check_services
            test_endpoints
            get_server_info
            ;;
        "logs")
            show_logs
            ;;
        "status")
            check_services
            ;;
        "test")
            test_endpoints
            ;;
        "fix")
            quick_fixes
            echo -e "${GREEN}✅ Quick fixes applied${NC}"
            ;;
        "info")
            get_server_info
            ;;
        "help")
            echo -e "${BLUE}Usage: $0 [COMMAND]${NC}"
            echo ""
            echo -e "${BLUE}Commands:${NC}"
            echo -e "  verify     - Complete verification (default)"
            echo -e "  logs       - Show recent logs"
            echo -e "  status     - Check services status"
            echo -e "  test       - Test HTTP endpoints"
            echo -e "  fix        - Apply quick fixes"
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

# Run main function
main "$@"
