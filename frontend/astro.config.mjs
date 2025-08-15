// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), tailwind()],
  output: 'static', // Static site generation
  
  vite: {
    plugins: [],
    define: {
      // Define API URL for build time
      'import.meta.env.API_URL': JSON.stringify(process.env.API_URL || 'http://localhost:3001')
    }
  }
});
