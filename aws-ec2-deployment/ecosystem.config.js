module.exports = {
  apps: [
    {
      name: 'giovanni-amodeo',
      script: '../dist/server/entry.mjs',
      instances: 'max', // Use all available CPU cores
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '0.0.0.0',
        MONGODB_URI: process.env.MONGODB_URI || 'mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0',
        DB_NAME: process.env.DB_NAME || 'giovanni',
        CORS_ORIGINS: process.env.CORS_ORIGINS || '*'
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '0.0.0.0',
        MONGODB_URI: process.env.MONGODB_URI,
        DB_NAME: process.env.DB_NAME || 'giovanni',
        CORS_ORIGINS: process.env.CORS_ORIGINS
      },
      // Logging
      log_file: './logs/combined.log',
      out_file: './logs/out.log',
      error_file: './logs/error.log',
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
      autorestart: true,
      
      // Environment variables
      env_file: '.env'
    }
  ],

  // Deployment configuration
  deploy: {
    production: {
      user: 'ec2-user',
      host: process.env.EC2_HOST,
      ref: 'origin/main',
      repo: process.env.GITHUB_REPO,
      path: '/home/ec2-user/giovanni-amodeo',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && npm run build && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
