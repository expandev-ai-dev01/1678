# AutoClean Frontend

A React-based frontend application for the AutoClean file cleanup tool.

## Features

- Identify and remove temporary files
- Detect duplicate files
- Clean folder structure
- Free up disk space

## Tech Stack

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router 7.9.3
- TanStack Query 5.90.2
- Axios 1.12.2
- Zustand 5.0.8

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
npm install
```

### Environment Setup

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### Development

```bash
npm run dev
```

Application will be available at `http://localhost:5173`

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
src/
├── app/              # Application configuration
├── assets/           # Static assets and styles
├── core/             # Core components and utilities
├── domain/           # Business domain modules
└── pages/            # Page components
```

## API Integration

The frontend connects to the backend API at:
- External endpoints: `/api/v1/external/`
- Internal endpoints: `/api/v1/internal/`

Configure the API URL in `.env` file.

## License

MIT