# Giovanni Amodeo - Separated Architecture Deployment

This document describes the new separated architecture with dedicated frontend and backend services.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users         │    │   Nginx         │    │   Backend API   │    │   MongoDB Atlas  │
│   (Browser)     │◄──►│   (Port 80)     │◄──►│   (Port 3001)   │◄──►│   (Database)    │
│                 │    │   Static Files  │    │   Express.js    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
giovanni-amodeo/
├── backend/                 # Node.js Express API Service
│   ├── src/
│   │   ├── server.js       # Main server file
│   │   ├── config/
│   │   │   └── database.js # Database configuration
│   │   └── routes/
│   │       ├── videos.js   # Video CRUD operations
│   │       └── health.js   # Health check endpoint
│   ├── package.json        # Backend dependencies
│   └── env.example         # Environment variables template
│
├── frontend/               # Static Astro Frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── layouts/        # Astro layouts
│   │   ├── pages/          # Astro pages (no API routes)
│   │   ├── lib/
│   │   │   └── api.js     # API client for backend
│   │   └── styles/         # CSS styles
│   ├── package.json        # Frontend dependencies
│   └── astro.config.mjs    # Astro configuration (static output)
│
├── deployment/             # Deployment Configuration
│   ├── deploy.sh          # Main deployment script
│   ├── ecosystem.config.js # PM2 configuration
│   ├── nginx.conf         # Nginx configuration
│   └── README.md          # This file
│
└── public/                # Static assets
```

## 🚀 Quick Deployment

### Prerequisites
- Ubuntu 20.04+ EC2 instance
- SSH access to the server
- Domain name (optional)

### One-Command Deployment
```bash
# SSH into your EC2 server
ssh -i your-key.pem ubuntu@your-ec2-ip

# Clone the repository
git clone https://github.com/your-username/giovanni-amodeo.git
cd giovanni-amodeo

# Run the deployment script
./deployment/deploy.sh deploy
```

## 🔧 Services

### Backend Service (Port 3001)
- **Technology**: Node.js + Express.js
- **Database**: MongoDB Atlas
- **Process Manager**: PM2 (clustered)
- **Features**:
  - RESTful API endpoints
  - MongoDB integration
  - Health checks
  - Error handling
  - CORS configuration
  - Request logging

#### API Endpoints
```
GET    /                    # API information
GET    /api/health          # Health check
GET    /api/docs            # API documentation
GET    /api/videos          # Get all videos
POST   /api/videos          # Create video
GET    /api/videos/:id      # Get video by ID
PUT    /api/videos/:id      # Update video
DELETE /api/videos/:id      # Delete video
```

### Frontend Service (Port 80)
- **Technology**: Astro (Static Site Generation)
- **UI Framework**: React + Tailwind CSS
- **Web Server**: Nginx
- **Features**:
  - Static file serving
  - Client-side routing
  - API integration
  - Responsive design
  - SEO optimized

## 📋 Deployment Commands

### Full Deployment
```bash
./deployment/deploy.sh deploy
```

### Partial Deployments
```bash
# Backend only
./deployment/deploy.sh backend

# Frontend only
./deployment/deploy.sh frontend

# Health check
./deployment/deploy.sh health

# View logs
./deployment/deploy.sh logs

# Service status
./deployment/deploy.sh status

# Server information
./deployment/deploy.sh info
```

## 🔍 Monitoring & Management

### Backend Management
```bash
# PM2 commands
pm2 status                    # Check status
pm2 logs giovanni-backend     # View logs
pm2 restart giovanni-backend  # Restart service
pm2 stop giovanni-backend     # Stop service
pm2 monit                     # Monitor resources

# Direct API testing
curl http://localhost:3001/api/health
curl http://localhost:3001/api/videos
```

### Frontend Management
```bash
# Nginx commands
sudo systemctl status nginx   # Check status
sudo systemctl reload nginx   # Reload configuration
sudo nginx -t                 # Test configuration

# Access logs
sudo tail -f /var/log/nginx/giovanni-amodeo.access.log
sudo tail -f /var/log/nginx/giovanni-amodeo.error.log
```

## 🌐 Access URLs

After deployment, your application will be accessible at:

- **Frontend**: `http://your-ec2-ip/`
- **Admin Panel**: `http://your-ec2-ip/admin/`
- **API Health**: `http://your-ec2-ip/api/health`
- **API Documentation**: `http://your-ec2-ip/api/docs`
- **Videos API**: `http://your-ec2-ip/api/videos`

## ⚙️ Configuration

### Backend Environment Variables
Create `/var/www/giovanni-amodeo/backend/.env`:
```bash
NODE_ENV=production
PORT=3001
MONGODB_URI=mongodb+srv://your-connection-string
DB_NAME=giovanni
CORS_ORIGINS=http://your-domain.com,https://your-domain.com
```

### Frontend API Configuration
The frontend automatically connects to the backend via the API client in `frontend/src/lib/api.js`.

## 🔒 Security Features

### Backend Security
- **Helmet.js**: Security headers
- **CORS**: Cross-origin request handling
- **Input validation**: Request validation
- **Error handling**: Secure error responses
- **Rate limiting**: API rate limiting via Nginx

### Frontend Security
- **Static serving**: No server-side vulnerabilities
- **CSP headers**: Content Security Policy
- **XSS protection**: Cross-site scripting prevention
- **HTTPS ready**: SSL/TLS configuration ready

## 📈 Performance Optimizations

### Backend Performance
- **PM2 Clustering**: Multi-core utilization
- **Connection pooling**: MongoDB connection reuse
- **Compression**: Gzip compression
- **Keep-alive**: HTTP keep-alive connections

### Frontend Performance
- **Static generation**: Pre-built HTML/CSS/JS
- **Asset caching**: Long-term browser caching
- **Gzip compression**: Compressed static assets
- **CDN ready**: Static assets can be served from CDN

## 🔧 Troubleshooting

### Common Issues

#### Backend Not Starting
```bash
# Check logs
pm2 logs giovanni-backend

# Check MongoDB connection
curl http://localhost:3001/api/health

# Restart service
pm2 restart giovanni-backend
```

#### Frontend Not Loading
```bash
# Check Nginx status
sudo systemctl status nginx

# Check Nginx configuration
sudo nginx -t

# Check file permissions
ls -la /var/www/giovanni-amodeo/frontend/dist/
```

#### API Connection Issues
```bash
# Test backend directly
curl http://localhost:3001/api/health

# Check CORS configuration
curl -H "Origin: http://your-domain.com" http://localhost:3001/api/health

# Check Nginx proxy
curl http://localhost/api/health
```

## 🚀 Benefits of Separated Architecture

### Development Benefits
- **Independent development**: Frontend and backend can be developed separately
- **Technology flexibility**: Each service can use optimal technologies
- **Easier testing**: Services can be tested independently
- **Clear separation**: Better code organization and maintainability

### Deployment Benefits
- **Independent scaling**: Scale frontend and backend separately
- **Independent updates**: Deploy services independently
- **Better resource utilization**: Optimize resources per service
- **Improved reliability**: Service isolation improves overall reliability

### Operational Benefits
- **Easier monitoring**: Monitor services separately
- **Better debugging**: Isolate issues to specific services
- **Flexible hosting**: Deploy services on different infrastructure
- **Cost optimization**: Optimize costs per service requirements

## 📚 Additional Resources

- **Express.js Documentation**: https://expressjs.com/
- **Astro Documentation**: https://docs.astro.build/
- **PM2 Documentation**: https://pm2.keymetrics.io/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **MongoDB Documentation**: https://docs.mongodb.com/

---

**Happy Deploying! 🚀**
