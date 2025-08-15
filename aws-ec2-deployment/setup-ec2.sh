#!/bin/bash

# AWS EC2 Setup Script for Giovanni Amodeo Project
# This script sets up an EC2 instance for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up AWS EC2 for Giovanni Amodeo Project${NC}"

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}❌ Please don't run this script as root${NC}"
        exit 1
    fi
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        OS=openSUSE
    elif [ -f /etc/redhat-release ]; then
        OS=RedHat
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo -e "${BLUE}Detected OS: $OS $VER${NC}"
}

# Function to update system packages
update_system() {
    echo -e "${YELLOW}📦 Updating system packages...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt update && sudo apt upgrade -y
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum update -y
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf update -y
    else
        echo -e "${RED}❌ Unsupported OS: $OS${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ System packages updated${NC}"
}

# Function to install Node.js
install_nodejs() {
    echo -e "${YELLOW}📦 Installing Node.js...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Install Node.js 18.x on Ubuntu/Debian
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        # Install Node.js 18.x on RHEL/CentOS/Amazon Linux
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Install Node.js 18.x on Fedora
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo dnf install -y nodejs
    else
        # Fallback: try to install via package manager
        echo -e "${YELLOW}Trying alternative Node.js installation...${NC}"
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -y nodejs npm
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y nodejs npm
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y nodejs npm
        else
            echo -e "${RED}❌ Could not install Node.js automatically${NC}"
            echo -e "${YELLOW}Please install Node.js 18+ manually and re-run this script${NC}"
            exit 1
        fi
    fi
    
    # Verify installation
    node_version=$(node --version)
    npm_version=$(npm --version)
    
    echo -e "${GREEN}✅ Node.js installed: ${node_version}${NC}"
    echo -e "${GREEN}✅ npm installed: ${npm_version}${NC}"
}

# Function to install PM2
install_pm2() {
    echo -e "${YELLOW}📦 Installing PM2...${NC}"
    sudo npm install -g pm2
    
    # Setup PM2 startup script
    pm2 startup
    
    echo -e "${GREEN}✅ PM2 installed${NC}"
}

# Function to install Nginx
install_nginx() {
    echo -e "${YELLOW}📦 Installing Nginx...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt-get install -y nginx
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum install -y nginx
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf install -y nginx
    else
        # Fallback
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -y nginx
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y nginx
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y nginx
        else
            echo -e "${RED}❌ Could not install Nginx automatically${NC}"
            exit 1
        fi
    fi
    
    # Enable and start Nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    echo -e "${GREEN}✅ Nginx installed and started${NC}"
}

# Function to install Git
install_git() {
    echo -e "${YELLOW}📦 Installing Git...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt-get install -y git
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum install -y git
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf install -y git
    else
        # Fallback
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -y git
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y git
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        else
            echo -e "${RED}❌ Could not install Git automatically${NC}"
            exit 1
        fi
    fi
    
    git_version=$(git --version)
    echo -e "${GREEN}✅ Git installed: ${git_version}${NC}"
}

# Function to install additional tools
install_tools() {
    echo -e "${YELLOW}📦 Installing additional tools...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt-get install -y \
            htop \
            curl \
            wget \
            unzip \
            vim \
            tree \
            jq
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum install -y \
            htop \
            curl \
            wget \
            unzip \
            vim \
            tree \
            jq
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf install -y \
            htop \
            curl \
            wget \
            unzip \
            vim \
            tree \
            jq
    else
        # Fallback - install common tools
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -y htop curl wget unzip vim tree jq
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y htop curl wget unzip vim tree jq
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y htop curl wget unzip vim tree jq
        fi
    fi
    
    echo -e "${GREEN}✅ Additional tools installed${NC}"
}

# Function to setup firewall
setup_firewall() {
    echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian uses UFW
        if command -v ufw >/dev/null 2>&1; then
            sudo ufw --force enable
            sudo ufw allow ssh
            sudo ufw allow http
            sudo ufw allow https
            sudo ufw allow 3000/tcp
            echo -e "${GREEN}✅ UFW firewall configured${NC}"
        else
            echo -e "${YELLOW}⚠️  UFW not available, skipping firewall configuration${NC}"
        fi
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
        # RHEL-based systems use firewalld
        if command -v firewall-cmd >/dev/null 2>&1; then
            sudo systemctl enable firewalld
            sudo systemctl start firewalld
            sudo firewall-cmd --permanent --add-service=http
            sudo firewall-cmd --permanent --add-service=https
            sudo firewall-cmd --permanent --add-port=3000/tcp
            sudo firewall-cmd --reload
            echo -e "${GREEN}✅ Firewalld configured${NC}"
        else
            echo -e "${YELLOW}⚠️  Firewalld not available, skipping firewall configuration${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Unknown firewall system, please configure manually${NC}"
    fi
}

# Function to create application directory
create_app_directory() {
    echo -e "${YELLOW}📁 Creating application directory...${NC}"
    
    # Create application directory
    sudo mkdir -p /var/www/giovanni-amodeo
    sudo chown -R $USER:$USER /var/www/giovanni-amodeo
    
    # Create logs directory
    mkdir -p /var/www/giovanni-amodeo/logs
    
    echo -e "${GREEN}✅ Application directory created${NC}"
}

# Function to setup environment file
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up environment variables...${NC}"
    
    # Create environment file
    cat > /var/www/giovanni-amodeo/.env << EOF
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
    
    echo -e "${GREEN}✅ Environment file created${NC}"
}

# Function to setup SSL certificate (Let's Encrypt)
setup_ssl() {
    echo -e "${YELLOW}🔒 Setting up SSL certificate...${NC}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt-get install -y certbot python3-certbot-nginx
    elif [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum install -y certbot python3-certbot-nginx
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf install -y certbot python3-certbot-nginx
    else
        # Try snap installation as fallback
        if command -v snap >/dev/null 2>&1; then
            sudo snap install --classic certbot
            sudo ln -sf /snap/bin/certbot /usr/bin/certbot
        else
            echo -e "${YELLOW}⚠️  Could not install Certbot automatically${NC}"
            echo -e "${YELLOW}Please install Certbot manually for SSL support${NC}"
        fi
    fi
    
    echo -e "${BLUE}📋 SSL setup completed. To get a certificate, run:${NC}"
    echo -e "${BLUE}   sudo certbot --nginx -d your-domain.com${NC}"
}

# Function to create deployment user
create_deployment_user() {
    echo -e "${YELLOW}👤 Setting up deployment user...${NC}"
    
    # Add current user to nginx group
    sudo usermod -a -G nginx $USER
    
    # Set proper permissions
    sudo chown -R $USER:nginx /var/www/giovanni-amodeo
    sudo chmod -R 755 /var/www/giovanni-amodeo
    
    echo -e "${GREEN}✅ Deployment user configured${NC}"
}

# Function to display summary
display_summary() {
    echo -e "${GREEN}🎉 EC2 Setup Complete!${NC}"
    echo -e "${BLUE}📋 Summary:${NC}"
    echo -e "${BLUE}   • Node.js: $(node --version)${NC}"
    echo -e "${BLUE}   • npm: $(npm --version)${NC}"
    echo -e "${BLUE}   • PM2: Installed${NC}"
    echo -e "${BLUE}   • Nginx: Running${NC}"
    echo -e "${BLUE}   • Git: $(git --version)${NC}"
    echo -e "${BLUE}   • Application directory: /var/www/giovanni-amodeo${NC}"
    echo ""
    echo -e "${YELLOW}📚 Next steps:${NC}"
    echo -e "${YELLOW}   1. Clone your repository to /var/www/giovanni-amodeo${NC}"
    echo -e "${YELLOW}   2. Run the deployment script${NC}"
    echo -e "${YELLOW}   3. Configure Nginx with the provided configuration${NC}"
    echo -e "${YELLOW}   4. Set up SSL certificate for your domain${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}🔧 Starting EC2 setup...${NC}"
    
    check_root
    detect_os
    update_system
    install_nodejs
    install_pm2
    install_nginx
    install_git
    install_tools
    setup_firewall
    create_app_directory
    setup_environment
    setup_ssl
    create_deployment_user
    display_summary
    
    echo -e "${GREEN}🚀 EC2 setup completed successfully!${NC}"
}

# Run main function
main
