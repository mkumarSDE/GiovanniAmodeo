# MongoDB Migration for Giovanni Amodeo Videos

This script migrates your existing video JSON data to MongoDB with metadata and views set to 0.

## Prerequisites

1. **Node.js** installed on your system
2. **MongoDB Atlas** cluster with connection string
3. Your existing JSON files in `public/api/` directory

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Update Connection String

Edit the `migrate-videos.js` file and replace `<db_password>` with your actual MongoDB password:

```javascript
const MONGODB_URI = 'mongodb+srv://worksmkumar:YOUR_ACTUAL_PASSWORD@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
```

### 3. Run Migration

```bash
npm run migrate
```

Or directly:

```bash
node migrate-videos.js
```

## What the Migration Does

### ✅ Creates Database
- Database name: `giovanni`
- Collections: `videos`

### ✅ Migrates Data
- **Videos**: All videos from `public/api/videos.json`
- **Metadata**: Views, likes, shares all set to 0 initially

### ✅ Creates Indexes
- Performance optimized indexes for fast queries
- Unique constraints on video IDs
- Compound indexes for filtering

### ✅ Data Structure

Each video document includes:

```javascript
{
  name: "Speaker Name",
  video_title: "Video Title",
  video_id: "wistia_id",
  speaker_type: "Private Equity",
  topic: "growth",
  sector: "finance",
  geography: "america",
  company_name: "Company Name",
  company_size: "Mid-Market",
  insights_link: "https://...",
  subtitle_file: "filename.txt",
  featured: false,
  metadata: {
    views: 0,
    likes: 0,
    shares: 0,
    duration: 0,
    quality: "1080p",
    language: "en"
  },
  publishedAt: new Date(),
  createdAt: new Date(),
  updatedAt: new Date()
}
```

## Expected Output

```
Connecting to MongoDB...
Connected to MongoDB successfully!
Clearing existing data...
Migrating videos...
✅ Migrated 500+ videos successfully!
Creating indexes...
✅ Indexes created successfully!

📊 Migration Summary:
📹 Total Videos: 500+
🗄️  Database: giovanni
🔗 Cluster: Cluster0

✅ Migration completed successfully!
🔌 MongoDB connection closed.
🎉 All done!
```

## Verification

After migration, you can verify the data in MongoDB Atlas:

1. Go to your MongoDB Atlas dashboard
2. Navigate to the `giovanni` database
3. Check the `videos` collection
4. Verify that all videos have metadata with views set to 0

## Troubleshooting

### Connection Issues
- Verify your MongoDB password is correct
- Check if your IP is whitelisted in MongoDB Atlas
- Ensure the cluster is running

### Data Issues
- Check that JSON files exist in `public/api/` directory
- Verify JSON files are valid
- Check console output for specific error messages

### Index Issues
- If indexes fail, the data will still be migrated
- You can manually create indexes later in MongoDB Atlas

## Next Steps

After successful migration:

1. **Update your application** to connect to MongoDB instead of JSON files
2. **Implement analytics tracking** to update the views, likes, shares
3. **Add admin interface** to manage videos
4. **Set up automated backups** for your MongoDB data

## Security Notes

- Never commit your actual MongoDB password to version control
- Use environment variables for production deployments
- Consider using MongoDB Atlas App Users for better security 