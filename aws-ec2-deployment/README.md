# AWS EC2 Deployment Guide for Giovanni Amodeo Project

This guide provides complete instructions for deploying your Astro + MongoDB project on AWS EC2.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users/CDN     │    │   Nginx         │    │   Node.js       │    │   MongoDB Atlas  │
│   (CloudFront)  │◄──►│   (Reverse      │◄──►│   (Express +    │◄──►│   (Database)    │
│                 │    │   Proxy)        │    │   Astro Build)  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### 1. AWS Account Setup
- **AWS Account**: Active AWS account with billing enabled
- **EC2 Instance**: Launch an Amazon Linux 2 EC2 instance
- **Security Groups**: Configure inbound rules for HTTP (80) and HTTPS (443)
- **Key Pair**: Create and download SSH key pair

### 2. Domain Setup (Optional)
- **Domain Name**: Register or configure a domain
- **DNS Configuration**: Point domain to EC2 public IP
- **SSL Certificate**: Set up Let's Encrypt for HTTPS

### 3. Local Development Tools
- **SSH Client**: For connecting to EC2 instance
- **Git**: For code repository management

## 🚀 Quick Deployment

### Step 1: Launch EC2 Instance
1. **Launch Instance**:
   - AMI: Amazon Linux 2
   - Instance Type: t3.small or larger
   - Storage: 20GB+ EBS volume
   - Security Group: Allow HTTP (80), HTTPS (443), SSH (22)

2. **Connect to Instance**:
   ```bash
   ssh -i your-key.pem ec2-user@your-ec2-ip
   ```

### Step 2: Run Setup Script
```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/giovanni-amodeo/main/aws-ec2-deployment/setup-ec2.sh | bash
```

Or manually:
```bash
# Clone your repository
git clone https://github.com/your-repo/giovanni-amodeo.git
cd giovanni-amodeo

# Run setup script
chmod +x aws-ec2-deployment/setup-ec2.sh
./aws-ec2-deployment/setup-ec2.sh
```

### Step 3: Deploy Application
```bash
# Run deployment script
chmod +x aws-ec2-deployment/deploy-to-ec2.sh
./aws-ec2-deployment/deploy-to-ec2.sh deploy
```

## 📁 Project Structure

```
aws-ec2-deployment/
├── package.json           # Node.js dependencies for deployment
├── server.js             # Express server for serving Astro build
├── ecosystem.config.js   # PM2 configuration
├── setup-ec2.sh         # EC2 instance setup script
├── deploy-to-ec2.sh     # Application deployment script
├── nginx.conf           # Nginx configuration
├── env.example          # Environment variables template
└── README.md            # This file
```

## 🔧 Configuration Files

### 1. Express Server (`server.js`)
- Serves static Astro build files
- Handles API routes through the built application
- Security middleware (Helmet, CORS)
- Compression and caching
- Health check endpoint

### 2. PM2 Configuration (`ecosystem.config.js`)
- Process management with clustering
- Auto-restart on failure
- Log management
- Environment variable configuration
- Memory management

### 3. Nginx Configuration (`nginx.conf`)
- Reverse proxy to Node.js application
- Static file serving with caching
- Rate limiting
- Security headers
- SSL/TLS configuration (when enabled)
- Gzip compression

## 🛠️ Deployment Commands

### Initial Deployment
```bash
./deploy-to-ec2.sh deploy
```

### Management Commands
```bash
# Check application status
./deploy-to-ec2.sh status

# View application logs
./deploy-to-ec2.sh logs

# Run health checks
./deploy-to-ec2.sh health

# Rollback to previous version
./deploy-to-ec2.sh rollback
```

### PM2 Commands
```bash
# View PM2 status
pm2 status

# View logs
pm2 logs giovanni-amodeo

# Restart application
pm2 restart giovanni-amodeo

# Stop application
pm2 stop giovanni-amodeo

# Monitor resources
pm2 monit
```

## 🌐 Domain and SSL Setup

### 1. Configure Domain
Update Nginx configuration with your domain:
```bash
sudo nano /etc/nginx/conf.d/giovanni-amodeo.conf
# Replace 'your-domain.com' with your actual domain
```

### 2. SSL Certificate with Let's Encrypt
```bash
# Install Certbot (already done by setup script)
sudo yum install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal (optional)
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔍 Monitoring and Logging

### Application Logs
```bash
# PM2 logs
pm2 logs giovanni-amodeo

# Application-specific logs
tail -f /var/www/giovanni-amodeo/aws-ec2-deployment/logs/combined.log
tail -f /var/www/giovanni-amodeo/aws-ec2-deployment/logs/error.log
```

### Nginx Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/giovanni-amodeo.access.log

# Error logs
sudo tail -f /var/log/nginx/giovanni-amodeo.error.log
```

### System Monitoring
```bash
# System resources
htop

# Disk usage
df -h

# Memory usage
free -h

# Network connections
netstat -tulpn
```

## 🔒 Security Configuration

### 1. Firewall Setup
```bash
# Check firewall status
sudo firewall-cmd --list-all

# Allow specific ports
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 2. Security Groups (AWS Console)
- **Inbound Rules**:
  - HTTP (80): 0.0.0.0/0
  - HTTPS (443): 0.0.0.0/0
  - SSH (22): Your IP only
- **Outbound Rules**: All traffic allowed

### 3. Application Security
- Environment variables for sensitive data
- Rate limiting in Nginx
- Security headers
- Input validation in API routes

## 📊 Performance Optimization

### 1. Nginx Optimizations
- Gzip compression enabled
- Static file caching
- Connection keep-alive
- Buffer optimizations

### 2. Node.js Optimizations
- PM2 clustering (uses all CPU cores)
- Memory management
- Connection pooling for MongoDB
- Caching headers

### 3. Database Optimizations
- MongoDB Atlas with proper indexing
- Connection caching
- Query optimization

## 🔧 Troubleshooting

### Common Issues

#### 1. Application Won't Start
```bash
# Check PM2 logs
pm2 logs giovanni-amodeo

# Check system logs
sudo journalctl -u nginx

# Check disk space
df -h

# Check memory
free -h
```

#### 2. Nginx Configuration Errors
```bash
# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check Nginx status
sudo systemctl status nginx
```

#### 3. Database Connection Issues
```bash
# Check environment variables
cat /var/www/giovanni-amodeo/.env

# Test MongoDB connection
mongo "mongodb+srv://your-connection-string"

# Check network connectivity
curl -I https://cluster0.oqejoev.mongodb.net
```

#### 4. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Test SSL configuration
openssl s_client -connect your-domain.com:443
```

### Debug Mode
```bash
# Run application in debug mode
cd /var/www/giovanni-amodeo/aws-ec2-deployment
NODE_ENV=development npm start

# Enable PM2 debug logs
pm2 start ecosystem.config.js --log-level debug
```

## 📈 Scaling

### Vertical Scaling (Upgrade Instance)
1. Stop application: `pm2 stop giovanni-amodeo`
2. Stop instance in AWS Console
3. Change instance type
4. Start instance
5. Start application: `pm2 start giovanni-amodeo`

### Horizontal Scaling (Load Balancer)
1. Create Application Load Balancer
2. Launch multiple EC2 instances
3. Configure health checks
4. Update DNS to point to load balancer

### Auto Scaling
1. Create AMI from configured instance
2. Create Launch Template
3. Configure Auto Scaling Group
4. Set up CloudWatch alarms

## 💰 Cost Optimization

### Instance Optimization
- **Right-sizing**: Start with t3.small, monitor and adjust
- **Reserved Instances**: For long-term deployments
- **Spot Instances**: For development environments

### Storage Optimization
- **EBS Optimization**: Use gp3 volumes
- **Log Rotation**: Configure log rotation to prevent disk fill
- **Cleanup**: Regular cleanup of old backups and logs

### Monitoring Costs
- **CloudWatch**: Monitor resource usage
- **AWS Cost Explorer**: Track spending
- **Billing Alerts**: Set up cost alerts

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Deploy to EC2
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to EC2
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ec2-user
          key: ${{ secrets.EC2_KEY }}
          script: |
            cd /var/www/giovanni-amodeo
            git pull origin main
            ./aws-ec2-deployment/deploy-to-ec2.sh deploy
```

## 🗑️ Cleanup and Removal

### Remove Application
```bash
# Stop and remove PM2 processes
pm2 stop giovanni-amodeo
pm2 delete giovanni-amodeo

# Remove Nginx configuration
sudo rm /etc/nginx/conf.d/giovanni-amodeo.conf
sudo systemctl reload nginx

# Remove application directory
sudo rm -rf /var/www/giovanni-amodeo
```

### Terminate EC2 Resources
1. Terminate EC2 instance
2. Delete security groups
3. Release Elastic IP (if used)
4. Delete load balancer (if configured)

## 📚 Additional Resources

- **AWS EC2 Documentation**: https://docs.aws.amazon.com/ec2/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **PM2 Documentation**: https://pm2.keymetrics.io/docs/
- **Let's Encrypt**: https://letsencrypt.org/
- **MongoDB Atlas**: https://docs.atlas.mongodb.com/

## 🆘 Support

### Monitoring and Alerts
- Set up CloudWatch monitoring
- Configure SNS notifications
- Monitor application health

### Backup Strategy
- Automated EBS snapshots
- Application backup scripts
- Database backups (MongoDB Atlas)

### Emergency Procedures
1. **Application Down**: Check PM2 status and logs
2. **High CPU**: Check processes and consider scaling
3. **Disk Full**: Clean logs and temporary files
4. **Memory Issues**: Restart PM2 or upgrade instance

---

**Happy Deploying on AWS EC2! 🚀**
