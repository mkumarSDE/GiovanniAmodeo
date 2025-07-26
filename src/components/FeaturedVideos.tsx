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

export default function FeaturedVideos() {
  const [videos, setVideos] = useState<Video[]>([]);
  const [visibleCount, setVisibleCount] = useState(30); // 10 rows of 3
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [thumbnails, setThumbnails] = useState<Record<string, string>>({});
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    fetch('/api/videos.json')
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

  const showMore = () => setVisibleCount((c) => c + 30); // Add 10 more rows (30 videos)

  const openVideoModal = (video: Video) => {
    setSelectedVideo(video);
    setIsModalOpen(true);
  };

  const closeVideoModal = () => {
    setIsModalOpen(false);
    setSelectedVideo(null);
  };

  return (
    <>
      <section className="py-16 md:py-20 bg-gradient-to-br from-gray-50 to-white min-h-screen">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="text-center mb-12 md:mb-16">
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 mb-4 md:mb-6 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Featured Videos
            </h2>
            <p className="text-lg sm:text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed font-medium px-4">
              Explore the latest insights and conversations with industry leaders
            </p>
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
              <div className="grid gap-4 sm:gap-6 md:gap-8 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
                {videos.slice(0, visibleCount - (visibleCount % 3)).map((video, idx) => (
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

              {visibleCount < videos.length && (
                <div className="flex justify-center mt-8 md:mt-12">
                  <button
                    onClick={showMore}
                    className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 md:px-8 py-3 md:py-4 rounded-full font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl text-base md:text-lg"
                  >
                    Show 10 More
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