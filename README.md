# Giovanni Amodeo Project

A modern web application built with **Astro** frontend and **FastAPI** backend, featuring video management capabilities.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Astro Frontend │    │   FastAPI Backend │    │   MongoDB Atlas  │
│   (Port 4321)   │◄──►│   (Port 8000)   │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### Start Astro Frontend (in new terminal)
```bash
npm install
npm run dev
```

## 📁 Project Structure

```
Giovanni Amodeo/
├── src/                     # Astro frontend
│   ├── components/          # React components
│   ├── pages/              # Astro pages
│   │   └── api/            # API proxy endpoints
│   └── styles/             # CSS styles
├── public/                  # Static assets
├── start-project.sh         # Automated startup script
└── README.md               # This file
```

