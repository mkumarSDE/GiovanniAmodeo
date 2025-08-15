module.exports = {
  apps: [
    {
      name: 'giovanni-backend',
      script: '../backend/src/server.js',
      instances: 'max',
      exec_mode: 'cluster',
      cwd: '../backend',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        MONGODB_URI: process.env.MONGODB_URI || 'mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0',
        DB_NAME: process.env.DB_NAME || 'giovanni',
        CORS_ORIGINS: process.env.CORS_ORIGINS || 'http://localhost:4321,http://localhost:3000'
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3001,
        MONGODB_URI: process.env.MONGODB_URI,
        DB_NAME: process.env.DB_NAME || 'giovanni',
        CORS_ORIGINS: process.env.CORS_ORIGINS
      },
      // Logging
      log_file: './logs/backend-combined.log',
      out_file: './logs/backend-out.log',
      error_file: './logs/backend-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm Z',
      
      // Restart policy
      restart_delay: 4000,
      max_restarts: 10,
      min_uptime: '10s',
      
      // Monitoring
      monitoring: true,
      
      // Advanced settings
      kill_timeout: 5000,
      listen_timeout: 8000,
      
      // Auto restart on file changes (disable in production)
      watch: false,
      ignore_watch: ['node_modules', 'logs'],
      
      // Memory management
      max_memory_restart: '1G',
      
      // Process management
      autorestart: true
    }
  ]
};
