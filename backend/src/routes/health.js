import express from 'express';
import { connectToDatabase } from '../config/database.js';

const router = express.Router();

router.get('/', async (req, res) => {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'Giovanni Amodeo Backend API',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    database: {
      status: 'disconnected',
      collections: 0,
      error: null
    }
  };

  // Test database connection
  try {
    const { db } = await connectToDatabase();
    const collections = await db.listCollections().toArray();
    
    healthCheck.database = {
      status: 'connected',
      collections: collections.length,
      names: collections.map(col => col.name)
    };
  } catch (error) {
    healthCheck.database = {
      status: 'error',
      error: error.message
    };
    healthCheck.status = 'unhealthy';
  }

  // Determine HTTP status code
  const statusCode = healthCheck.status === 'healthy' ? 200 : 503;

  res.status(statusCode).json(healthCheck);
});

export { router as healthRoutes };
