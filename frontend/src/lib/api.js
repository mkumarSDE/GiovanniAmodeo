// API client for backend communication

const API_BASE_URL = import.meta.env.API_URL || 'http://localhost:3001';

class ApiClient {
  constructor(baseURL = API_BASE_URL) {
    this.baseURL = baseURL;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    if (config.body && typeof config.body === 'object') {
      config.body = JSON.stringify(config.body);
    }

    try {
      const response = await fetch(url, config);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || `HTTP ${response.status}: ${response.statusText}`);
      }

      return data;
    } catch (error) {
      console.error(`API request failed: ${config.method || 'GET'} ${url}`, error);
      throw error;
    }
  }

  // Health check
  async health() {
    return this.request('/api/health');
  }

  // Video endpoints
  async getVideos() {
    const response = await this.request('/api/videos');
    return response.data || [];
  }

  async getVideo(id) {
    const response = await this.request(`/api/videos/${id}`);
    return response.data;
  }

  async createVideo(videoData) {
    return this.request('/api/videos', {
      method: 'POST',
      body: videoData,
    });
  }

  async updateVideo(id, videoData) {
    return this.request(`/api/videos/${id}`, {
      method: 'PUT',
      body: videoData,
    });
  }

  async deleteVideo(id) {
    return this.request(`/api/videos/${id}`, {
      method: 'DELETE',
    });
  }
}

export const api = new ApiClient();
export default api;
