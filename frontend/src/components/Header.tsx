import { useState, useEffect } from 'react';
import LoginModal from './LoginModal';

export default function Header() {
	const [isMenuOpen, setIsMenuOpen] = useState(false);
	const [isVideosPage, setIsVideosPage] = useState(false);
	const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
	const [isAuthenticated, setIsAuthenticated] = useState(false);
	
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

	useEffect(() => {
		// Check authentication status
		const authStatus = localStorage.getItem('adminAuthenticated');
		setIsAuthenticated(!!authStatus);
	}, []);

	const handleLogin = async (username: string, password: string) => {
		// Simple authentication - you can replace this with your own logic
		if (username === 'admin' && password === 'password123') {
			localStorage.setItem('adminAuthenticated', 'true');
			setIsAuthenticated(true);
			setIsLoginModalOpen(false);
			window.location.href = '/admin';
		} else {
			throw new Error('Invalid credentials');
		}
	};

	const handleLogout = () => {
		localStorage.removeItem('adminAuthenticated');
		setIsAuthenticated(false);
		window.location.href = '/';
	};

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

						{/* Login/Admin Icon */}
						{isAuthenticated ? (
							<div className="flex items-center space-x-2">
								<a 
									href="/admin" 
									className="p-2 text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
									title="Go to Admin Dashboard"
								>
									<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
									</svg>
								</a>
								<button 
									onClick={handleLogout}
									className="p-2 text-red-600 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors"
									title="Logout"
								>
									<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
									</svg>
								</button>
							</div>
						) : (
							<button 
								onClick={() => setIsLoginModalOpen(true)}
								className="p-2 text-gray-600 hover:text-blue-600 hover:bg-gray-100 rounded-lg transition-colors"
								title="Admin Login"
							>
								<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
								</svg>
							</button>
						)}

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

		{/* Login Modal */}
		<LoginModal
			isOpen={isLoginModalOpen}
			onClose={() => setIsLoginModalOpen(false)}
			onLogin={handleLogin}
		/>
		</>
	);
} 