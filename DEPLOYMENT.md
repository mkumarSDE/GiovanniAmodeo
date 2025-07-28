# Deployment Guide for AWS Amplify

## Build Configuration

The project is configured for static generation to work with AWS Amplify:

- **Static Output**: All pages are pre-rendered at build time
- **Client-side Features**: Interactive features work via JavaScript
- **No Server Required**: Works with static hosting

## Build Process

1. **Pre-build**: `npm ci` (installs dependencies)
2. **Build**: `npm run build` (creates static files)
3. **Deploy**: Static files are served directly

## Features

### ✅ Working Features
- **Home Page**: Fully responsive with all sections
- **Videos Page**: Static video gallery with filters
- **Contact Modal**: Client-side functionality
- **Responsive Design**: Works on all devices

### ⚠️ Removed Features (for static deployment)
- **Admin Dashboard**: Requires server-side rendering
- **API Routes**: MongoDB integration removed
- **Dynamic Video Management**: Replaced with static content

## Static Pages

- `/` - Home page with all sections
- `/videos` - Video gallery with filters
- All assets and images included

## Future Enhancements

To add back dynamic features, consider:
1. **External API**: Connect to a separate backend service
2. **Different Hosting**: Use Vercel, Netlify, or Railway for SSR
3. **Headless CMS**: Use Contentful, Strapi, or similar 