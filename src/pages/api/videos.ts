import type { APIRoute } from 'astro';

const FASTAPI_BASE_URL = 'http://localhost:8000';

export const GET: APIRoute = async () => {
  try {
    const response = await fetch(`${FASTAPI_BASE_URL}/videos`);
    const data = await response.json();
    
    return new Response(JSON.stringify(data.data || []), {
      status: response.status,
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

    const response = await fetch(`${FASTAPI_BASE_URL}/videos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    
    if (!response.ok) {
      return new Response(JSON.stringify({ error: data.detail || 'Failed to create video' }), {
        status: response.status,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    return new Response(JSON.stringify({ 
      message: data.message || 'Video created successfully',
      id: data.data?._id 
    }), {
      status: response.status,
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