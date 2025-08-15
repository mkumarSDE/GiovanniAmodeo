import express from 'express';
import { ObjectId } from 'mongodb';
import { getCollection } from '../config/database.js';

const router = express.Router();

// Get all videos
router.get('/', async (req, res) => {
  try {
    const collection = await getCollection('videos');
    const videos = await collection.find({}).toArray();
    
    res.json({
      success: true,
      data: videos,
      count: videos.length
    });
  } catch (error) {
    console.error('Error fetching videos:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch videos',
      details: error.message
    });
  }
});

// Get single video by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid video ID format'
      });
    }

    const collection = await getCollection('videos');
    const video = await collection.findOne({ _id: new ObjectId(id) });
    
    if (!video) {
      return res.status(404).json({
        success: false,
        error: 'Video not found'
      });
    }

    res.json({
      success: true,
      data: video
    });
  } catch (error) {
    console.error('Error fetching video:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch video',
      details: error.message
    });
  }
});

// Create new video
router.post('/', async (req, res) => {
  try {
    const { video_id, name, topic, sector, views = 0 } = req.body;
    
    // Validate required fields
    if (!video_id || !name || !topic || !sector) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
        required: ['video_id', 'name', 'topic', 'sector']
      });
    }

    const collection = await getCollection('videos');
    
    // Check if video_id already exists
    const existingVideo = await collection.findOne({ video_id });
    if (existingVideo) {
      return res.status(409).json({
        success: false,
        error: 'Video ID already exists'
      });
    }

    // Create video document
    const videoData = {
      video_id,
      name,
      topic,
      sector,
      views: parseInt(views) || 0,
      created_at: new Date(),
      updated_at: new Date()
    };

    const result = await collection.insertOne(videoData);
    
    res.status(201).json({
      success: true,
      message: 'Video created successfully',
      data: {
        _id: result.insertedId,
        ...videoData
      }
    });
  } catch (error) {
    console.error('Error creating video:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create video',
      details: error.message
    });
  }
});

// Update video by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body };
    
    if (!ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid video ID format'
      });
    }

    // Remove _id from update data if present
    delete updateData._id;
    
    // Add updated timestamp
    updateData.updated_at = new Date();

    const collection = await getCollection('videos');
    const result = await collection.updateOne(
      { _id: new ObjectId(id) },
      { $set: updateData }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        error: 'Video not found'
      });
    }

    // Get updated video
    const updatedVideo = await collection.findOne({ _id: new ObjectId(id) });

    res.json({
      success: true,
      message: 'Video updated successfully',
      data: updatedVideo
    });
  } catch (error) {
    console.error('Error updating video:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update video',
      details: error.message
    });
  }
});

// Delete video by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid video ID format'
      });
    }

    const collection = await getCollection('videos');
    const result = await collection.deleteOne({ _id: new ObjectId(id) });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        error: 'Video not found'
      });
    }

    res.json({
      success: true,
      message: 'Video deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting video:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete video',
      details: error.message
    });
  }
});

export { router as videoRoutes };
