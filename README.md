# Astro + React + Tailwind CSS Project

This is a modern web development project that combines the power of Astro, React, and Tailwind CSS.

## 🚀 Features

- **Astro**: Modern static site generator with excellent performance
- **React**: Interactive components with full client-side functionality
- **Tailwind CSS**: Utility-first CSS framework for rapid UI development
- **TypeScript**: Full TypeScript support for better development experience

## 📁 Project Structure

```
src/
├── components/     # React components
├── layouts/        # Astro layout components
├── pages/          # Astro pages (routes)
└── styles/         # Global styles and Tailwind CSS
```

## 🛠️ Getting Started

### Prerequisites

- Node.js (version 18 or higher)
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

### Development

Start the development server:

```bash
npm run dev
```

The site will be available at `http://localhost:4321`

### Building for Production

Build the project for production:

```bash
npm run build
```

### Preview Production Build

Preview the production build locally:

```bash
npm run preview
```

## 🎨 Using React Components

React components can be used in Astro pages with different hydration strategies:

- `client:load` - Hydrates immediately on page load
- `client:idle` - Hydrates when the browser is idle
- `client:visible` - Hydrates when the component enters the viewport
- `client:media` - Hydrates based on media queries

Example:
```astro
---
import MyReactComponent from '../components/MyReactComponent';
---

<MyReactComponent client:load />
```

## 🎯 Tailwind CSS

This project uses Tailwind CSS v4 with the new `@import "tailwindcss"` syntax. All Tailwind utility classes are available throughout the project.

## 📝 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run astro` - Run Astro CLI commands

## 🔧 Configuration

- `astro.config.mjs` - Astro configuration with React and Tailwind CSS
- `tsconfig.json` - TypeScript configuration
- `src/styles/global.css` - Global styles with Tailwind CSS import

## 📚 Learn More

- [Astro Documentation](https://docs.astro.build/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
