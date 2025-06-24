import React, { useState, useMemo } from "react";

export default function VideoGallery({ videos }) {
  // ✅ Filter out invalid videos
  const cleanedVideos = videos.filter(
    (v) => v.video_id && v.video_id.trim() !== ""
  );

  // ✅ Get unique values for each filter
  const getUniqueValues = (key) => [
    ...new Set(cleanedVideos.flatMap((v) => (Array.isArray(v[key]) ? v[key].map(s => s.trim()) : v[key] ? [v[key].trim()] : []))),
  ];

  const filters = {
    speaker_type: getUniqueValues("speaker_type"),
    topic: getUniqueValues("topic"),
    size: getUniqueValues("size"),
    geography: getUniqueValues("geography"),
    sector: getUniqueValues("sector"),
    company_name: getUniqueValues("company_name"),
    company_size: getUniqueValues("company_size"),
  };

  // ✅ Filter state
  const [selectedFilters, setSelectedFilters] = useState({
    speaker_type: "",
    topic: "",
    size: "",
    geography: "",
    sector: "",
    company_name: "",
    company_size: "",
  });

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setSelectedFilters((prev) => ({ ...prev, [name]: value }));
    setVisibleCount(videosPerPage); // Reset visible count on filter change
  };

  const videosPerPage = 30;
  const [visibleCount, setVisibleCount] = useState(videosPerPage);
  const [loading, setLoading] = useState(false);

  const loadMore = () => {
    if (visibleCount >= filteredVideos.length) return;
    setLoading(true);
    setTimeout(() => {
      setVisibleCount((prev) => Math.min(prev + videosPerPage, filteredVideos.length));
      setLoading(false);
    }, 800);
  };

  // ✅ Apply filters
  const filteredVideos = useMemo(() => {
    return cleanedVideos.filter((video) => {
      return Object.entries(selectedFilters).every(([key, value]) => {
        if (!value) return true;
        const field = video[key];
        if (Array.isArray(field)) {
          return field.map((s) => s.trim().toLowerCase()).includes(value.toLowerCase());
        } else {
          return field?.toLowerCase() === value.toLowerCase();
        }
      });
    });
  }, [selectedFilters, cleanedVideos]);

  return (
    <section id="featured" className="py-20 px-6 bg-gray-50">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-4xl font-bold text-center text-gray-800 mb-12">
          🎥 Featured Interviews
        </h2>

        {/* ✅ Filters */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-12">
          {Object.entries(filters).map(([key, values]) => (
            <select
              key={key}
              name={key}
              value={selectedFilters[key]}
              onChange={handleFilterChange}
              className="p-2 border border-gray-300 rounded-md bg-white text-gray-700"
            >
              <option value="">All {key.replace(/_/g, " ")}</option>
              {values.map((v) => (
                <option key={v} value={v}>
                  {v}
                </option>
              ))}
            </select>
          ))}
        </div>

        {/* ✅ Video Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredVideos.slice(0, visibleCount).map((video) => (
            <section
              key={video.video_id}
              id={video.video_id}
              className="bg-white rounded-lg shadow-md overflow-hidden"
            >
              <div
                className="wistia_responsive_padding"
                style={{ padding: "56.25% 0 0 0", position: "relative" }}
              >
                <div
                  className="wistia_responsive_wrapper"
                  style={{
                    height: "100%",
                    left: 0,
                    position: "absolute",
                    top: 0,
                    width: "100%",
                  }}
                >
                  <iframe
                    src={`https://fast.wistia.net/embed/iframe/${video.video_id}`}
                    title={video.video_title}
                    allow="autoplay; fullscreen"
                    allowtransparency="true"
                    frameBorder="0"
                    scrolling="no"
                    className="w-full h-full"
                  />
                </div>
              </div>
              <div className="p-4">
                <h3 className="text-lg font-semibold text-gray-800">{video.video_title}</h3>
              </div>
            </section>
          ))}
        </div>

        {/* ✅ Load More Button */}
        {visibleCount < filteredVideos.length && (
          <button
            onClick={loadMore}
            disabled={loading}
            className="fixed bottom-6 right-6 z-50 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-full shadow-lg px-6 py-3 text-sm font-bold hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out"
            title="Load more videos"
          >
            {loading ? "Loading..." : "➕ Load More"}
          </button>
        )}
      </div>
    </section>
  );
}
