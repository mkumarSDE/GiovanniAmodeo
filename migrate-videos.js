import { MongoClient } from 'mongodb';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// MongoDB connection string (replace <db_password> with your actual password)
const MONGODB_URI = 'mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const DB_NAME = 'giovanni';

// Read JSON files
const videosData = JSON.parse(fs.readFileSync(path.join(__dirname, 'public/api/videos.json'), 'utf8'));

async function migrateVideos() {
  let client;
  
  try {
    // Connect to MongoDB
    console.log('Connecting to MongoDB...');
    client = new MongoClient(MONGODB_URI);
    await client.connect();
    console.log('Connected to MongoDB successfully!');
    
    const db = client.db(DB_NAME);
    
    // Create collections
    const videosCollection = db.collection('videos');
    
    // Clear existing data (optional - remove if you want to keep existing data)
    console.log('Clearing existing data...');
    await videosCollection.deleteMany({});
    
    // Migrate main videos
    console.log('Migrating videos...');
    const videosToInsert = videosData.map(video => ({
      name: video.name,
      video_title: video.video_title,
      video_id: video.video_id || '',
      speaker_type: video.speaker_type,
      topic: video.topic,
      size: video.size || [],
      geography: video.geography,
      sector: video.sector,
      company_name: video.company_name,
      company_size: video.company_size,
      insights_link: video.insights_link,
      subtitle_file: video.subtitle_file,
      featured: false,
      // Metadata with views set to 0
      metadata: {
        views: 0,
        likes: 0,
        shares: 0,
        duration: 0, // in seconds
        quality: '1080p',
        language: 'en'
      },
      publishedAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date()
    }));
    
    if (videosToInsert.length > 0) {
      const result = await videosCollection.insertMany(videosToInsert);
      console.log(`✅ Migrated ${result.insertedCount} videos successfully!`);
    }
    
    // Create indexes for better performance
    console.log('Creating indexes...');
    // Create regular index on video_id (not unique since many are empty)
    await videosCollection.createIndex({ "video_id": 1 });
    await videosCollection.createIndex({ "topic": 1, "publishedAt": -1 });
    await videosCollection.createIndex({ "sector": 1, "publishedAt": -1 });
    await videosCollection.createIndex({ "geography": 1, "publishedAt": -1 });
    await videosCollection.createIndex({ "speaker_type": 1, "publishedAt": -1 });
    await videosCollection.createIndex({ "featured": 1, "publishedAt": -1 });
    await videosCollection.createIndex({ "company_name": 1 });
    await videosCollection.createIndex({ "name": 1 });
    await videosCollection.createIndex({ "publishedAt": -1 });
    
    console.log('✅ Indexes created successfully!');
    
    // Display summary
    const totalVideos = await videosCollection.countDocuments();
    
    console.log('\n📊 Migration Summary:');
    console.log(`📹 Total Videos: ${totalVideos}`);
    console.log(`🗄️  Database: ${DB_NAME}`);
    console.log(`🔗 Cluster: Cluster0`);
    
    console.log('\n✅ Migration completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    if (client) {
      await client.close();
      console.log('🔌 MongoDB connection closed.');
    }
  }
}

// Run migration
migrateVideos()
  .then(() => {
    console.log('🎉 All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Migration failed:', error);
    process.exit(1);
  }); 