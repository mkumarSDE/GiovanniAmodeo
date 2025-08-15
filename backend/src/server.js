import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { config } from './config/database.js';
import { videoRoutes } from './routes/videos.js';
import { healthRoutes } from './routes/health.js';

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      connectSrc: ["'self'", "https://cluster0.oqejoev.mongodb.net"],
    },
  },
}));

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',') : ['http://localhost:4321', 'http://localhost:3000'],
  credentials: true
}));

// Compression middleware
app.use(compression());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/videos', videoRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Giovanni Amodeo API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/api/health',
      videos: '/api/videos',
      documentation: '/api/docs'
    }
  });
});

// API documentation endpoint
app.get('/api/docs', (req, res) => {
  res.json({
    title: 'Giovanni Amodeo API Documentation',
    version: '1.0.0',
    endpoints: [
      {
        path: '/api/health',
        method: 'GET',
        description: 'Health check endpoint'
      },
      {
        path: '/api/videos',
        method: 'GET',
        description: 'Get all videos'
      },
      {
        path: '/api/videos',
        method: 'POST',
        description: 'Create a new video',
        body: {
          video_id: 'string (required)',
          name: 'string (required)',
          topic: 'string (required)',
          sector: 'string (required)',
          views: 'number (optional)'
        }
      },
      {
        path: '/api/videos/:id',
        method: 'GET',
        description: 'Get video by ID'
      },
      {
        path: '/api/videos/:id',
        method: 'PUT',
        description: 'Update video by ID'
      },
      {
        path: '/api/videos/:id',
        method: 'DELETE',
        description: 'Delete video by ID'
      }
    ]
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `${req.method} ${req.originalUrl} not found`,
    availableEndpoints: [
      'GET /',
      'GET /api/health',
      'GET /api/docs',
      'GET /api/videos',
      'POST /api/videos',
      'GET /api/videos/:id',
      'PUT /api/videos/:id',
      'DELETE /api/videos/:id'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📱 Health check: http://localhost:${PORT}/api/health`);
  console.log(`📚 API docs: http://localhost:${PORT}/api/docs`);
});
