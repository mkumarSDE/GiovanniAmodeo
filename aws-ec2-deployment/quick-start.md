# Quick Start Guide - AWS EC2 Deployment

Get your Giovanni Amodeo project running on AWS EC2 in under 30 minutes!

## 🚀 Prerequisites (5 minutes)

### 1. AWS Account & EC2 Instance
- Launch Amazon Linux 2 EC2 instance (t3.small recommended)
- Configure Security Group: Allow ports 22, 80, 443
- Download your SSH key pair

### 2. Connect to EC2
```bash
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

## ⚡ One-Command Setup (10 minutes)

### Option 1: Automated Setup
```bash
# Clone repository and run setup
git clone https://github.com/your-username/giovanni-amodeo.git
cd giovanni-amodeo
chmod +x aws-ec2-deployment/setup-ec2.sh
./aws-ec2-deployment/setup-ec2.sh
```

### Option 2: Manual Commands
```bash
# Update system
sudo yum update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PM2 and Nginx
sudo npm install -g pm2
sudo yum install -y nginx git

# Enable services
sudo systemctl enable nginx
sudo systemctl start nginx
pm2 startup
```

## 🎯 Deploy Application (10 minutes)

```bash
# Navigate to project directory
cd giovanni-amodeo

# Run deployment script
chmod +x aws-ec2-deployment/deploy-to-ec2.sh
./aws-ec2-deployment/deploy-to-ec2.sh deploy
```

## ✅ Verify Deployment (5 minutes)

### 1. Check Application Status
```bash
pm2 status
curl http://localhost:3000/health
```

### 2. Check Nginx
```bash
sudo systemctl status nginx
curl http://your-ec2-public-ip
```

### 3. Test API Endpoints
```bash
curl http://your-ec2-public-ip/api/videos
curl http://your-ec2-public-ip/health
```

## 🌐 Access Your Application

- **Website**: `http://your-ec2-public-ip`
- **Admin Panel**: `http://your-ec2-public-ip/admin`
- **API**: `http://your-ec2-public-ip/api/videos`
- **Health Check**: `http://your-ec2-public-ip/health`

## 🔧 Quick Commands

### Application Management
```bash
# View logs
pm2 logs giovanni-amodeo

# Restart application
pm2 restart giovanni-amodeo

# Stop application
pm2 stop giovanni-amodeo

# Deploy updates
./aws-ec2-deployment/deploy-to-ec2.sh deploy
```

### System Management
```bash
# Check system resources
htop
df -h
free -h

# Nginx management
sudo systemctl status nginx
sudo systemctl reload nginx
sudo nginx -t
```

## 🔒 Optional: SSL Setup (5 minutes)

### 1. Configure Domain
```bash
# Update Nginx configuration with your domain
sudo nano /etc/nginx/conf.d/giovanni-amodeo.conf
# Replace 'your-domain.com' with your actual domain
```

### 2. Get SSL Certificate
```bash
sudo certbot --nginx -d your-domain.com
```

## 🎉 You're Done!

Your Giovanni Amodeo project is now live on AWS EC2!

### Next Steps:
1. **Custom Domain**: Point your domain to the EC2 IP
2. **SSL Certificate**: Set up HTTPS with Let's Encrypt
3. **Monitoring**: Set up CloudWatch monitoring
4. **Backups**: Configure automated backups
5. **CI/CD**: Set up automated deployments

### Need Help?
- Check logs: `pm2 logs giovanni-amodeo`
- View full documentation: `aws-ec2-deployment/README.md`
- Health check: `curl http://your-ip/health`

**🚀 Happy deploying!**
