# Deployment Guide for AWS Amplify

## Environment Variables

Set these environment variables in your AWS Amplify console:

- `MONGODB_URI`: Your MongoDB connection string
- `DB_NAME`: Database name (default: giovanni)
- `NODE_ENV`: Set to `production`

## Build Configuration

The project is configured with:
- `@astrojs/node` adapter for server-side rendering
- `amplify.yml` for build configuration
- Standalone mode for optimal performance

## Build Process

1. **Pre-build**: `npm ci` (installs dependencies)
2. **Build**: `npm run build` (creates production build)
3. **Start**: `node ./dist/server/entry.mjs` (runs the server)

## API Routes

The following API routes are available:
- `GET /api/videos` - Fetch all videos
- `POST /api/videos` - Create new video
- `GET /api/videos/[id]` - Fetch single video
- `PUT /api/videos/[id]` - Update video
- `DELETE /api/videos/[id]` - Delete video

## Admin Access

- Login: `admin` / `password123`
- Admin Dashboard: `/admin`
- Video Management: `/admin/videos` 