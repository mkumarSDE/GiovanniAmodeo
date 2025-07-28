import { MongoClient } from 'mongodb';
import type { APIRoute } from 'astro';

const MONGODB_URI = 'mongodb+srv://worksmkumar:oGwcLJr6hXhbRBbh@cluster0.oqejoev.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const DB_NAME = 'giovanni';

let cachedClient: MongoClient | null = null;

async function getMongoClient() {
  if (cachedClient) return cachedClient;
  const client = new MongoClient(MONGODB_URI);
  await client.connect();
  cachedClient = client;
  return client;
}

export const GET: APIRoute = async () => {
  try {
    const client = await getMongoClient();
    const db = client.db(DB_NAME);
    const videos = await db.collection('videos').find({}).toArray();
    
    return new Response(JSON.stringify(videos), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: 'Failed to fetch videos', 
      details: String(error)
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
};

export const POST: APIRoute = async ({ request }) => {
  try {
    const body = await request.json();
    
    // Validate required fields
    if (!body.video_id || !body.name || !body.topic || !body.sector) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const client = await getMongoClient();
    const db = client.db(DB_NAME);
    const collection = db.collection('videos');

    // Check if video_id already exists
    const existingVideo = await collection.findOne({ video_id: body.video_id });
    if (existingVideo) {
      return new Response(JSON.stringify({ error: 'Video ID already exists' }), {
        status: 409,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Add default values
    const videoData = {
      ...body,
      views: body.views || 0,
      created_at: new Date(),
      updated_at: new Date()
    };

    const result = await collection.insertOne(videoData);
    
    return new Response(JSON.stringify({ 
      message: 'Video created successfully',
      id: result.insertedId 
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    console.error('Error creating video:', error);
    return new Response(JSON.stringify({ error: 'Failed to create video' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}; 