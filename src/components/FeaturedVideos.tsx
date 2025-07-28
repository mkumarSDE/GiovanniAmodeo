import { useEffect, useState } from 'react';

interface Video {
  name: string;
  insights_link: string;
  video_id: string;
  subtitle_file: string;
  speaker_type: string;
  topic: string;
  size: string[] | null;
  geography: string;
  sector: string;
  company_name: string | null;
  company_size: string;
  video_title: string;
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

export default function FeaturedVideos() {
  const [videos, setVideos] = useState<Video[]>([]);
  const [filteredVideos, setFilteredVideos] = useState<Video[]>([]);
  const [visibleCount, setVisibleCount] = useState(30);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [thumbnails, setThumbnails] = useState<Record<string, string>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [filters, setFilters] = useState<Filters>({
    topic: '',
    sector: '',
    geography: '',
    speaker_type: '',
    company_size: '',
    search: ''
  });
  const [showFilters, setShowFilters] = useState(false);

  // Get unique filter options
  const getUniqueOptions = (field: keyof Video) => {
    const options = videos.map(video => {
      const value = video[field];
      if (field === 'size' && Array.isArray(value)) {
        return value.join(', '); // Convert array to string for size field
      }
      return value as string;
    }).filter(Boolean) as string[];
    return [...new Set(options)].sort();
  };

  // Apply filters
  useEffect(() => {
    let filtered = videos;

    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      filtered = filtered.filter(video =>
        video.name.toLowerCase().includes(searchLower) ||
        video.video_title.toLowerCase().includes(searchLower) ||
        video.company_name?.toLowerCase().includes(searchLower) ||
        video.topic.toLowerCase().includes(searchLower) ||
        video.sector.toLowerCase().includes(searchLower)
      );
    }

    if (filters.topic) {
      filtered = filtered.filter(video => video.topic === filters.topic);
    }

    if (filters.sector) {
      filtered = filtered.filter(video => video.sector === filters.sector);
    }

    if (filters.geography) {
      filtered = filtered.filter(video => video.geography === filters.geography);
    }

    if (filters.speaker_type) {
      filtered = filtered.filter(video => video.speaker_type === filters.speaker_type);
    }

    if (filters.company_size) {
      filtered = filtered.filter(video => video.company_size === filters.company_size);
    }

    setFilteredVideos(filtered);
    setVisibleCount(30); // Reset visible count when filters change
  }, [videos, filters]);

  useEffect(() => {
    setIsLoading(true);
    fetch('/api/videos')
      .then((res) => res.json())
      .then((data) => {
        console.log('Total videos loaded:', data.length);
        
        // Filter only videos that have a valid video_id
        const videosWithId = data.filter((video: Video) => {
          const hasValidId = video.video_id && 
                           video.video_id.trim() !== '' && 
                           video.video_id.length > 0;
          
          if (!hasValidId) {
            console.log('Filtered out video without valid ID:', video.name);
          }
          
          return hasValidId;
        });
        
        console.log('Videos with valid video_id:', videosWithId.length);
        setVideos(videosWithId);
        setIsLoading(false);
        
        // Fetch thumbnails for all videos with video_id
        videosWithId.forEach((video: Video) => {
          fetchWistiaThumbnail(video.video_id);
        });
      })
      .catch((error) => {
        console.error('Error loading videos:', error);
        setIsLoading(false);
      });
  }, []);

  const fetchWistiaThumbnail = async (videoId: string) => {
    try {
      const response = await fetch(
        `https://fast.wistia.net/oembed?url=http://home.wistia.com/medias/${videoId}?embedType=async_popover&videoWidth=900&popoverWidth=640&popoverHeight=350`
      );
      const data: WistiaData = await response.json();
      
      if (data.thumbnail_url) {
        const thumbnailUrl = `${data.thumbnail_url}&image_resize=640`;
        setThumbnails(prev => ({
          ...prev,
          [videoId]: thumbnailUrl
        }));
      }
    } catch (error) {
      console.log('Failed to fetch thumbnail for:', videoId);
    }
  };

  const showMore = () => setVisibleCount((c) => c + 30);

  const openVideoModal = (video: Video) => {
    setSelectedVideo(video);
    setIsModalOpen(true);
  };

  const closeVideoModal = () => {
    setIsModalOpen(false);
    setSelectedVideo(null);
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

  const hasActiveFilters = Object.values(filters).some(value => value !== '');

  return (
    <>
      <section className="py-16 md:py-20 bg-gradient-to-br from-gray-50 to-white min-h-screen">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="text-center mb-12 md:mb-16">
            {/* Creative Title Section */}
            <div className="relative mb-8">
              {/* Background decorative elements */}
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-32 h-32 bg-gradient-to-r from-blue-100 to-purple-100 rounded-full opacity-20 blur-xl"></div>
              </div>
              
              {/* Main Title */}
              <h2 className="relative text-4xl sm:text-5xl md:text-6xl font-black text-gray-900 mb-2">
                <span className="bg-gradient-to-r from-blue-600 via-purple-600 to-purple-800 bg-clip-text text-transparent">
                  Fireside Chats
                </span>
              </h2>
              
              {/* Subtitle with creative styling */}
              <div className="relative mt-4">
                <p className="text-lg sm:text-xl text-gray-600 font-medium">
                  <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent font-semibold">
                    Discover
                  </span>{" "}
                  the latest insights and conversations with{" "}
                  <span className="bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent font-semibold">
                    industry leaders
                  </span>
                </p>
              </div>
              
              {/* Decorative line */}
              <div className="mt-6 flex justify-center">
                <div className="w-24 h-1 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full"></div>
              </div>
            </div>
            
            {/* Stats or additional info */}
            <div className="flex justify-center items-center space-x-8 text-sm text-gray-500 mb-8">
              <div className="flex items-center space-x-2">
                <svg className="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
                <span>Premium Content</span>
              </div>
              <div className="flex items-center space-x-2">
                <svg className="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                <span>Expert Speakers</span>
              </div>
              <div className="flex items-center space-x-2">
                <svg className="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>Latest Insights</span>
              </div>
            </div>
          </div>

          {/* Filters Section */}
          <div className="mb-8 md:mb-12">
            {/* Filter Toggle Button */}
            <div className="flex justify-between items-center mb-6">
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setShowFilters(!showFilters)}
                  className="flex items-center space-x-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-4 py-2 rounded-lg font-medium hover:from-blue-700 hover:to-purple-700 transition-all duration-300 shadow-lg"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.207A1 1 0 013 6.5V4z" />
                  </svg>
                  <span>Filters</span>
                </button>
                {hasActiveFilters && (
                  <button
                    onClick={clearFilters}
                    className="text-red-600 hover:text-red-700 font-medium text-sm"
                  >
                    Clear All
                  </button>
                )}
              </div>
              <div className="text-sm text-gray-600">
                {filteredVideos.length} of {videos.length} videos
              </div>
            </div>

            {/* Filters Panel */}
            {showFilters && (
              <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 mb-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
                  {/* Search */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Search</label>
                    <input
                      type="text"
                      placeholder="Search videos, speakers, topics..."
                      value={filters.search}
                      onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  {/* Topic */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Topic</label>
                    <select
                      value={filters.topic}
                      onChange={(e) => setFilters(prev => ({ ...prev, topic: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Topics</option>
                      {getUniqueOptions('topic').map(topic => (
                        <option key={topic} value={topic}>{topic}</option>
                      ))}
                    </select>
                  </div>

                  {/* Sector */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Sector</label>
                    <select
                      value={filters.sector}
                      onChange={(e) => setFilters(prev => ({ ...prev, sector: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Sectors</option>
                      {getUniqueOptions('sector').map(sector => (
                        <option key={sector} value={sector}>{sector}</option>
                      ))}
                    </select>
                  </div>

                  {/* Geography */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Geography</label>
                    <select
                      value={filters.geography}
                      onChange={(e) => setFilters(prev => ({ ...prev, geography: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Regions</option>
                      {getUniqueOptions('geography').map(geo => (
                        <option key={geo} value={geo}>{geo}</option>
                      ))}
                    </select>
                  </div>

                  {/* Speaker Type */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Speaker Type</label>
                    <select
                      value={filters.speaker_type}
                      onChange={(e) => setFilters(prev => ({ ...prev, speaker_type: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Speaker Types</option>
                      {getUniqueOptions('speaker_type').map(type => (
                        <option key={type} value={type}>{type}</option>
                      ))}
                    </select>
                  </div>

                  {/* Company Size */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Company Size</label>
                    <select
                      value={filters.company_size}
                      onChange={(e) => setFilters(prev => ({ ...prev, company_size: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="">All Company Sizes</option>
                      {getUniqueOptions('company_size').map(size => (
                        <option key={size} value={size}>{size}</option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>
            )}

            {/* Active Filters Display */}
            {hasActiveFilters && (
              <div className="flex flex-wrap gap-2 mb-6">
                {Object.entries(filters).map(([key, value]) => {
                  if (value && key !== 'search') {
                    return (
                      <span
                        key={key}
                        className="inline-flex items-center space-x-1 bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium"
                      >
                        <span>{key}: {value}</span>
                        <button
                          onClick={() => setFilters(prev => ({ ...prev, [key]: '' }))}
                          className="ml-1 text-blue-600 hover:text-blue-800"
                        >
                          <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                          </svg>
                        </button>
                      </span>
                    );
                  }
                  return null;
                })}
              </div>
            )}
          </div>

          {isLoading ? (
            <div className="flex justify-center items-center py-20">
              <div className="text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
                <p className="text-gray-600">Loading videos...</p>
              </div>
            </div>
          ) : (
            <>
              {filteredVideos.length === 0 ? (
                <div className="text-center py-20">
                  <div className="text-gray-400 mb-4">
                    <svg className="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.29-1.009-5.824-2.562M15 6.334A7.97 7.97 0 0012 5c-2.34 0-4.29.999-5.824 2.562M12 15c-2.34 0-4.29-1.009-5.824-2.562" />
                    </svg>
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">No videos found</h3>
                  <p className="text-gray-600 mb-4">Try adjusting your filters or search terms</p>
                  <button
                    onClick={clearFilters}
                    className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-2 rounded-lg font-medium hover:from-blue-700 hover:to-purple-700 transition-all duration-300"
                  >
                    Clear Filters
                  </button>
                </div>
              ) : (
                <div className="grid gap-4 sm:gap-6 md:gap-8 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
                  {filteredVideos.slice(0, visibleCount - (visibleCount % 3)).map((video, idx) => (
                    <div key={video.video_id + idx} className="bg-white rounded-2xl md:rounded-3xl shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 border border-gray-100 overflow-hidden flex flex-col cursor-pointer group" onClick={() => openVideoModal(video)}>
                      {/* Video Thumbnail */}
                      <div className="relative aspect-video w-full bg-gradient-to-br from-blue-600 to-purple-600 overflow-hidden">
                        {/* Thumbnail Image */}
                        {thumbnails[video.video_id] && (
                          <img 
                            src={thumbnails[video.video_id]}
                            alt={video.video_title}
                            className="absolute inset-0 w-full h-full object-cover"
                          />
                        )}
                        
                        {/* Gradient overlay for better text readability */}
                        <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
                        
                        {/* Play Button */}
                        <div className="absolute inset-0 flex items-center justify-center">
                          <div className="bg-white rounded-full p-3 md:p-4 shadow-lg transform group-hover:scale-110 transition-transform duration-300">
                            <svg className="w-6 h-6 md:w-8 md:h-8 text-blue-600" fill="currentColor" viewBox="0 0 24 24">
                              <path d="M8 5v14l11-7z"/>
                            </svg>
                          </div>
                        </div>
                        
                        {/* Video info overlay */}
                        <div className="absolute bottom-0 left-0 right-0 p-3 md:p-4">
                          <div className="text-white text-sm md:text-base font-medium truncate">
                            {video.name}
                          </div>
                          {video.company_name && (
                            <div className="text-white/80 text-xs md:text-sm truncate">
                              {video.company_name}
                            </div>
                          )}
                        </div>
                      </div>
                      <div className="p-4 md:p-6 flex-1 flex flex-col">
                        <h3 className="text-base md:text-lg font-bold text-gray-900 mb-2 leading-tight line-clamp-2">
                          {video.video_title}
                        </h3>
                        <div className="mb-2 text-xs md:text-sm text-gray-600">
                          <span className="font-semibold text-blue-600">{video.name}</span>
                          {video.company_name && <span> &middot; {video.company_name}</span>}
                        </div>
                        <div className="flex flex-wrap gap-1 md:gap-2 mb-3">
                          <span className="bg-gradient-to-r from-blue-500 to-purple-500 text-white px-2 md:px-3 py-1 rounded-full text-xs font-semibold">
                            {video.topic}
                          </span>
                          <span className="bg-gradient-to-r from-green-500 to-blue-500 text-white px-2 md:px-3 py-1 rounded-full text-xs font-semibold">
                            {video.sector}
                          </span>
                        </div>
                        <a
                          href={video.insights_link}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-blue-600 hover:text-blue-800 text-xs md:text-sm underline mb-2"
                          onClick={(e) => e.stopPropagation()}
                        >
                          Insights &rarr;
                        </a>
                        <div className="text-xs text-gray-400 mt-auto">
                          {video.speaker_type} • {video.geography}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {visibleCount < filteredVideos.length && (
                <div className="flex justify-center mt-8 md:mt-12">
                  <button
                    onClick={showMore}
                    className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 md:px-8 py-3 md:py-4 rounded-full font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl text-base md:text-lg"
                  >
                    Show More
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </section>

      {/* Video Modal */}
      {isModalOpen && selectedVideo && (
        <div className="fixed inset-0 bg-black bg-opacity-75 backdrop-blur-sm z-50 flex items-center justify-center p-2 sm:p-4" onClick={closeVideoModal}>
          <div className="bg-white rounded-2xl md:rounded-3xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden" onClick={(e) => e.stopPropagation()}>
            {/* Close Button */}
            <button
              onClick={closeVideoModal}
              className="absolute top-2 right-2 sm:top-4 sm:right-4 z-10 bg-white rounded-full p-2 shadow-lg hover:bg-gray-100 transition-colors"
            >
              <svg className="w-5 h-5 md:w-6 md:h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            {/* Video Player */}
            <div className="relative aspect-video w-full bg-black">
              <iframe
                src={`https://fast.wistia.net/embed/iframe/${selectedVideo.video_id}`}
                allow="autoplay; fullscreen"
                allowFullScreen
                title={selectedVideo.video_title}
                className="w-full h-full"
                loading="lazy"
              ></iframe>
            </div>

            {/* Video Info */}
            <div className="p-4 md:p-6">
              <h3 className="text-lg md:text-xl font-bold text-gray-900 mb-2 md:mb-3">
                {selectedVideo.video_title}
              </h3>
              <div className="mb-2 md:mb-3 text-xs md:text-sm text-gray-600">
                <span className="font-semibold text-blue-600">{selectedVideo.name}</span>
                {selectedVideo.company_name && <span> &middot; {selectedVideo.company_name}</span>}
              </div>
              <div className="flex flex-wrap gap-1 md:gap-2 mb-3 md:mb-4">
                <span className="bg-gradient-to-r from-blue-500 to-purple-500 text-white px-2 md:px-3 py-1 rounded-full text-xs font-semibold">
                  {selectedVideo.topic}
                </span>
                <span className="bg-gradient-to-r from-green-500 to-blue-500 text-white px-2 md:px-3 py-1 rounded-full text-xs font-semibold">
                  {selectedVideo.sector}
                </span>
              </div>
              <div className="mb-3 md:mb-4 text-xs md:text-sm text-gray-600 space-y-1">
                <p><strong>Speaker Type:</strong> {selectedVideo.speaker_type}</p>
                <p><strong>Geography:</strong> {selectedVideo.geography}</p>
                <p><strong>Company Size:</strong> {selectedVideo.company_size}</p>
              </div>
              <a
                href={selectedVideo.insights_link}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center space-x-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-4 md:px-6 py-2 md:py-3 rounded-full font-semibold hover:shadow-lg transition-all duration-300 text-sm md:text-base"
              >
                <span>Read Insights</span>
                <svg className="w-3 h-3 md:w-4 md:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            </div>
          </div>
        </div>
      )}
    </>
  );
} 