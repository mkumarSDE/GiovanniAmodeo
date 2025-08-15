const express = require('express');
const path = require('path');
const compression = require('compression');
const helmet = require('helmet');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'production';

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://cluster0.oqejoev.mongodb.net"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
}));

// Compression middleware
app.use(compression());

// CORS middleware
app.use(cors({
  origin: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',') : ['*'],
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve static files from the Astro build
app.use(express.static(path.join(__dirname, '../dist'), {
  maxAge: '1y',
  etag: true,
  lastModified: true,
  setHeaders: (res, path) => {
    if (path.endsWith('.html')) {
      res.setHeader('Cache-Control', 'public, max-age=0, must-revalidate');
    }
  }
}));

// API routes proxy (for development compatibility)
app.use('/api', (req, res, next) => {
  // In production, API routes are handled by the static build
  // This is just a fallback
  res.status(404).json({ error: 'API route not found in production build' });
});

// Serve the Astro app for all other routes
app.get('*', (req, res) => {
  // Handle client-side routing
  if (req.path.startsWith('/api/')) {
    return res.status(404).json({ error: 'API endpoint not found' });
  }
  
  // Serve the appropriate HTML file based on the route
  let filePath = path.join(__dirname, '../dist', req.path);
  
  // If it's a directory or doesn't exist, try index.html
  if (req.path === '/' || !path.extname(req.path)) {
    if (req.path === '/') {
      filePath = path.join(__dirname, '../dist/index.html');
    } else {
      // Try the specific route's index.html
      filePath = path.join(__dirname, '../dist', req.path, 'index.html');
    }
  }
  
  res.sendFile(filePath, (err) => {
    if (err) {
      // Fallback to main index.html for client-side routing
      res.sendFile(path.join(__dirname, '../dist/index.html'));
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    port: PORT
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${NODE_ENV}`);
  console.log(`📱 Health check: http://localhost:${PORT}/health`);
});
