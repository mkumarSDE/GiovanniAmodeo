import { useState, useEffect } from 'react';

export default function Header() {
	const [isMenuOpen, setIsMenuOpen] = useState(false);
	const [isVideosPage, setIsVideosPage] = useState(false);
	
	useEffect(() => {
		// Check if we're on the videos page after component mounts
		const checkCurrentPage = () => {
			const path = window.location.pathname;
			setIsVideosPage(path === '/videos');
		};
		
		checkCurrentPage();
		
		// Listen for route changes
		const handleRouteChange = () => {
			checkCurrentPage();
		};
		
		window.addEventListener('popstate', handleRouteChange);
		
		return () => {
			window.removeEventListener('popstate', handleRouteChange);
		};
	}, []);

	const openContactModal = () => {
		// Dispatch a custom event that Alpine.js can listen to
		window.dispatchEvent(new CustomEvent('openContactModal'));
	};

	return (
		<>
			<header className="sticky top-0 z-50 bg-white shadow-md border-b border-gray-200">
			<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
				<div className="flex justify-between items-center h-16">
					{/* Logo and Brand */}
					<a href="/" className="flex items-center space-x-3 hover:opacity-80 transition-opacity">
						<div className="flex items-center justify-center w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg">
							<span className="text-white font-bold text-lg">GA</span>
						</div>
						<div>
							<h1 className="text-2xl font-bold text-gray-900">Giovanni Amodeo</h1>
						</div>
					</a>

					{/* Desktop Navigation - Hidden on videos page */}
					{!isVideosPage && (
						<nav className="hidden md:flex items-center space-x-8">
							<a href="/#about" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								About
							</a>
							<a href="/#timeline" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Experience
							</a>
							<a href="/#services" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Services
							</a>
							<a href="/#testimonial" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Testimonials
							</a>
							<a href="/videos" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Videos
							</a>
						</nav>
					)}

					{/* Right Side Actions */}
					<div className="flex items-center space-x-4">
						{/* Contact Me Button */}
						<button 
							className="hidden sm:flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors font-medium"
							onClick={openContactModal}
						>
							<svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h14a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V5z" />
								<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5l9 6 9-6" />
							</svg>
							<span>Contact Me</span>
						</button>



						{/* Mobile Menu Button - Hidden on videos page */}
						{!isVideosPage && (
							<button
								onClick={() => setIsMenuOpen(!isMenuOpen)}
								className="md:hidden p-2 text-gray-600 hover:text-blue-600 hover:bg-gray-100 rounded-lg transition-colors"
							>
								<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
								</svg>
							</button>
						)}
					</div>
				</div>

				{/* Mobile Menu - Hidden on videos page */}
				{!isVideosPage && isMenuOpen && (
					<div className="md:hidden py-4 border-t border-gray-200">
						<div className="flex flex-col space-y-3">
							<a href="/#about" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								About
							</a>
							<a href="/#timeline" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Experience
							</a>
							<a href="/#services" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Services
							</a>
							<a href="/#testimonial" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Testimonials
							</a>
							<a href="/videos" className="text-gray-700 hover:text-blue-600 transition-colors font-medium">
								Videos
							</a>
							<div className="pt-3">
								<button 
									className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors font-medium w-full justify-center"
									onClick={openContactModal}
								>
									<svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h14a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V5z" />
										<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5l9 6 9-6" />
									</svg>
									<span>Contact Me</span>
								</button>
							</div>
						</div>
					</div>
				)}
			</div>
		</header>

		</>
	);
} 