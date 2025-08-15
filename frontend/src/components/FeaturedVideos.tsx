import { useEffect, useState } from 'react';

interface Video {
  _id: string;
  name: string;
  insights_link?: string;
  video_id: string;
  subtitle_file?: string;
  speaker_type?: string;
  topic: string;
  size?: string[] | null;
  geography?: string;
  sector: string;
  company_name?: string | null;
  company_size?: string;
  video_title?: string;
  views?: number;
  created_at?: string;
  updated_at?: string;
}

interface WistiaData {
  thumbnail_url: string;
  html: string;
  title: string;
}

interface Filters {
  topic: string;
  sector: string;
  geography: string;
  speaker_type: string;
  company_size: string;
  search: string;
}

const FeaturedVideos = () => {
  const [videos, setVideos] = useState<(Video & { wistia?: WistiaData })[]>([]);
  const [filteredVideos, setFilteredVideos] = useState<(Video & { wistia?: WistiaData })[]>([]);
  const [filters, setFilters] = useState<Filters>({
    topic: '',
    sector: '',
    geography: '',
    speaker_type: '',
    company_size: '',
    search: ''
  });
  const [isLoading, setIsLoading] = useState(true);
  const [selectedVideo, setSelectedVideo] = useState<(Video & { wistia?: WistiaData }) | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchVideos = async () => {
    try {
      // Import API client dynamically for client-side usage
      const { api } = await import('../lib/api.js');
      const videosData = await api.getVideos();
      
      // Filter videos to only include those with valid video_id
      const validVideos = videosData.filter((video: Video) => 
        video.video_id && video.video_id.trim() !== ''
      );
      
      console.log(`Filtered ${videosData.length} videos to ${validVideos.length} with valid video IDs`);
      
      // Fetch Wistia data for each valid video
      const videosWithWistia = await Promise.all(
        validVideos.map(async (video: Video) => {
          try {
            const wistiaResponse = await fetch(`https://fast.wistia.net/oembed?url=https://giovanni.wistia.com/medias/${video.video_id}&format=json`);
            if (wistiaResponse.ok) {
              const wistiaData: WistiaData = await wistiaResponse.json();
              return {
                ...video,
                wistia: wistiaData
              };
            } else {
              console.warn(`Wistia API returned ${wistiaResponse.status} for video ${video.video_id}`);
            }
          } catch (error) {
            console.error(`Failed to fetch Wistia data for video ${video.video_id}:`, error);
          }
          return video;
        })
      );
      
      setVideos(videosWithWistia);
      setFilteredVideos(videosWithWistia);
    } catch (error) {
      console.error('Failed to fetch videos:', error);
      setVideos([]);
      setFilteredVideos([]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchVideos();
  }, []);

  // Handle ESC key to close modal
  useEffect(() => {
    const handleEscKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && isModalOpen) {
        closeVideoModal();
      }
    };

    if (isModalOpen) {
      document.addEventListener('keydown', handleEscKey);
      // Prevent body scroll when modal is open
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscKey);
      document.body.style.overflow = 'unset';
    };
  }, [isModalOpen]);

  useEffect(() => {
    let filtered = videos;

    if (filters.topic) {
      filtered = filtered.filter(video =>
        video.topic?.toLowerCase().includes(filters.topic.toLowerCase())
      );
    }

    if (filters.sector) {
      filtered = filtered.filter(video => 
        video.sector?.toLowerCase().includes(filters.sector.toLowerCase())
      );
    }

    if (filters.geography) {
      filtered = filtered.filter(video => 
        video.geography?.toLowerCase().includes(filters.geography.toLowerCase())
      );
    }

    if (filters.speaker_type) {
      filtered = filtered.filter(video => 
        video.speaker_type?.toLowerCase().includes(filters.speaker_type.toLowerCase())
      );
    }

    if (filters.company_size) {
      filtered = filtered.filter(video => 
        video.company_size?.toLowerCase().includes(filters.company_size.toLowerCase())
      );
    }

    if (filters.search) {
      filtered = filtered.filter(video => 
        video.name?.toLowerCase().includes(filters.search.toLowerCase()) ||
        video.topic?.toLowerCase().includes(filters.search.toLowerCase()) ||
        video.sector?.toLowerCase().includes(filters.search.toLowerCase()) ||
        video.company_name?.toLowerCase().includes(filters.search.toLowerCase())
      );
    }

    setFilteredVideos(filtered);
  }, [filters, videos]);

  const handleFilterChange = (filterName: keyof Filters, value: string) => {
    setFilters(prev => ({
          ...prev,
      [filterName]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      topic: '',
      sector: '',
      geography: '',
      speaker_type: '',
      company_size: '',
      search: ''
    });
  };

  const openVideoModal = (video: Video & { wistia?: WistiaData }) => {
    setSelectedVideo(video);
    setIsModalOpen(true);
  };

  const closeVideoModal = () => {
    setSelectedVideo(null);
    setIsModalOpen(false);
  };

  if (isLoading) {
    return (
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading videos...</p>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-gray-900 sm:text-4xl">
            Featured Videos
              </h2>
          <p className="mt-4 text-xl text-gray-600">
            Insights from industry leaders and experts
                </p>
              </div>
              
        {/* Filters */}
        <div className="mb-8 space-y-4">
          <div className="flex flex-wrap gap-4">
                    <input
                      type="text"
              placeholder="Search videos..."
                      value={filters.search}
              onChange={(e) => handleFilterChange('search', e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />

                    <select
                      value={filters.topic}
              onChange={(e) => handleFilterChange('topic', e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Topics</option>
              {Array.from(new Set(videos.map(v => v.topic).filter(Boolean))).map(topic => (
                        <option key={topic} value={topic}>{topic}</option>
                      ))}
                    </select>

                    <select
                      value={filters.sector}
              onChange={(e) => handleFilterChange('sector', e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Sectors</option>
              {Array.from(new Set(videos.map(v => v.sector).filter(Boolean))).map(sector => (
                        <option key={sector} value={sector}>{sector}</option>
                      ))}
                    </select>

                  <button
                    onClick={clearFilters}
              className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                  >
                    Clear Filters
                  </button>
                </div>

          <p className="text-sm text-gray-600">
            Showing {filteredVideos.length} of {videos.length} videos
          </p>
        </div>

        {/* Videos Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredVideos.map((video) => (
            <div key={video._id} className="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300">
              {video.wistia?.thumbnail_url ? (
                <img
                  src={video.wistia.thumbnail_url}
                  alt={video.name}
                  className="w-full h-48 object-cover"
                />
              ) : (
                <div className="w-full h-48 bg-gray-200 flex items-center justify-center">
                  <span className="text-gray-400">No thumbnail</span>
                </div>
              )}
              
              <div className="p-6">
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  {video.name}
                </h3>
                
                <div className="space-y-2 text-sm text-gray-600 mb-4">
                  <p><strong>Topic:</strong> {video.topic}</p>
                  <p><strong>Sector:</strong> {video.sector}</p>
                          {video.company_name && (
                    <p><strong>Company:</strong> {video.company_name}</p>
                  )}
                  {video.views !== undefined && (
                    <p><strong>Views:</strong> {video.views}</p>
                          )}
                        </div>

                <div className="flex space-x-2">
                  <button 
                    onClick={() => openVideoModal(video)}
                    className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Watch Video
                  </button>
                  {video.insights_link && (
                        <a
                          href={video.insights_link}
                          target="_blank"
                          rel="noopener noreferrer"
                      className="flex-1 bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors text-center"
                        >
                      Insights
                        </a>
                  )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>

        {filteredVideos.length === 0 && !isLoading && (
          <div className="text-center py-12">
            <p className="text-gray-600">No videos found matching your criteria.</p>
                </div>
          )}
        </div>

      {/* Video Modal */}
      {isModalOpen && selectedVideo && (
          <div 
            className="video-modal fixed inset-0 bg-black bg-opacity-90 flex items-center justify-center z-50 p-4"
            onClick={closeVideoModal}
          >
            <div 
              className="video-container relative w-full max-w-5xl aspect-video"
              onClick={(e) => e.stopPropagation()}
            >
            {/* Close Button */}
            <button
              onClick={closeVideoModal}
                className="close-button absolute -top-12 right-0 text-white hover:text-gray-300 text-3xl font-bold z-10 transition-colors"
                aria-label="Close video"
            >
                ×
            </button>

            {/* Video Player */}
              {selectedVideo.wistia?.html ? (
                <div 
                  className="w-full h-full rounded-lg overflow-hidden"
                  dangerouslySetInnerHTML={{ 
                    __html: selectedVideo.wistia.html.replace(
                      /<iframe[^>]*>/g, 
                      '<iframe class="w-full h-full" frameborder="0" allowfullscreen>'
                    )
                  }}
                />
              ) : selectedVideo.video_id ? (
              <iframe
                  src={`https://giovanni.wistia.com/medias/${selectedVideo.video_id}`}
                  className="w-full h-full rounded-lg"
                  frameBorder="0"
                  allowFullScreen
                allow="autoplay; fullscreen"
              ></iframe>
              ) : (
                <div className="w-full h-full bg-gray-800 rounded-lg flex items-center justify-center">
                  <p className="text-white text-xl">Video player not available</p>
            </div>
              )}
          </div>
        </div>
      )}
      </section>
  );
};

export default FeaturedVideos;