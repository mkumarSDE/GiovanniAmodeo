# Giovanni Amodeo - Separated Architecture

A modern web application with separated frontend and backend services, optimized for scalability and maintainability.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users         │    │   Nginx         │    │   Backend API   │    │   MongoDB Atlas  │
│   (Browser)     │◄──►│   (Port 80)     │◄──►│   (Port 3001)   │◄──►│   (Database)    │
│                 │    │   Static Files  │    │   Express.js    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Ubuntu 20.04+ EC2 instance
- Node.js 18+ 
- MongoDB Atlas account
- Domain name (optional)

### One-Command Deployment
```bash
# SSH into your EC2 server
ssh -i your-key.pem ubuntu@your-ec2-ip

# Clone and deploy
git clone https://github.com/your-username/giovanni-amodeo.git
cd giovanni-amodeo
./deployment/deploy.sh deploy
```

## 📁 Project Structure

```
giovanni-amodeo/
├── backend/                 # Node.js Express API
│   ├── src/
│   │   ├── server.js       # Main server
│   │   ├── config/         # Database config
│   │   └── routes/         # API routes
│   └── package.json
│
├── frontend/               # Static Astro Site
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/          # Astro pages
│   │   └── lib/api.js     # API client
│   └── package.json
│
├── deployment/             # Deployment Scripts
│   ├── deploy.sh          # Main deployment script
│   ├── ecosystem.config.js # PM2 configuration
│   └── nginx.conf         # Nginx configuration
│
└── public/                # Static assets
```

## 🛠️ Services

### Backend Service (Port 3001)
- **Express.js** API server
- **MongoDB** integration
- **PM2** process management
- **RESTful** endpoints

### Frontend Service (Port 80)
- **Astro** static site generation
- **React** components
- **Nginx** web server
- **Tailwind CSS** styling

## 🌐 API Endpoints

```
GET    /api/health          # Health check
GET    /api/videos          # Get all videos
POST   /api/videos          # Create video
GET    /api/videos/:id      # Get video by ID
PUT    /api/videos/:id      # Update video
DELETE /api/videos/:id      # Delete video
```

## 📋 Deployment Commands

```bash
# Full deployment
./deployment/deploy.sh deploy

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
```

## 🔍 Management

### Backend Management
```bash
pm2 status                    # Check status
pm2 logs giovanni-backend     # View logs
pm2 restart giovanni-backend  # Restart
```

### Frontend Management
```bash
sudo systemctl status nginx   # Nginx status
sudo nginx -t                 # Test config
sudo systemctl reload nginx   # Reload
```

## 🌍 Access URLs

After deployment:
- **Frontend**: `http://your-ec2-ip/`
- **Admin**: `http://your-ec2-ip/admin/`
- **API**: `http://your-ec2-ip/api/health`
- **Docs**: `http://your-ec2-ip/api/docs`

## ⚙️ Configuration

### Backend Environment
Create `backend/.env`:
```bash
NODE_ENV=production
PORT=3001
MONGODB_URI=your-mongodb-connection-string
DB_NAME=giovanni
CORS_ORIGINS=http://your-domain.com
```

## 🔒 Security Features

- **Helmet.js** security headers
- **CORS** configuration
- **Rate limiting** via Nginx
- **Input validation**
- **XSS protection**
- **Static file serving**

## 📈 Performance

- **PM2 clustering** for backend
- **Static generation** for frontend
- **Gzip compression**
- **Asset caching**
- **Connection pooling**

## 🚀 Benefits

### Development
- **Independent services** development
- **Technology flexibility**
- **Easier testing**
- **Clear separation**

### Deployment
- **Independent scaling**
- **Independent updates**
- **Better resource utilization**
- **Improved reliability**

## 🔧 Troubleshooting

### Backend Issues
```bash
pm2 logs giovanni-backend     # Check logs
curl http://localhost:3001/api/health  # Test API
```

### Frontend Issues
```bash
sudo systemctl status nginx   # Check Nginx
sudo tail -f /var/log/nginx/error.log  # Error logs
```

## 📚 Documentation

Detailed documentation available in:
- `deployment/README.md` - Deployment guide
- `backend/src/` - Backend API documentation
- `frontend/src/` - Frontend component documentation

## 🆘 Support

For deployment issues:
1. Check the deployment logs
2. Review service status
3. Test individual components
4. Check firewall settings

---

**Built with ❤️ for scalable web applications**