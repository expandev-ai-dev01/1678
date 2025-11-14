# AutoClean Backend

Backend API for AutoClean - File management system for identifying and removing temporary files.

## Features

- RESTful API architecture
- TypeScript for type safety
- Express.js framework
- SQL Server database integration
- Multi-tenancy support
- Comprehensive error handling
- Request validation with Zod
- API versioning

## Prerequisites

- Node.js 18+ 
- SQL Server 2019+
- npm or yarn

## Installation

1. Clone the repository
2. Install dependencies:
```bash
npm install
```

3. Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

4. Update environment variables in `.env`

## Development

Start development server:
```bash
npm run dev
```

## Build

Build for production:
```bash
npm run build
```

## Production

Start production server:
```bash
npm start
```

## Testing

Run tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm run test:watch
```

## Linting

Run ESLint:
```bash
npm run lint
```

Fix linting issues:
```bash
npm run lint:fix
```

## Project Structure

```
src/
├── api/              # API controllers
├── routes/           # Route definitions
├── middleware/       # Express middleware
├── services/         # Business logic
├── utils/            # Utility functions
├── constants/        # Application constants
├── instances/        # Service instances
├── config/           # Configuration
└── server.ts         # Application entry point
```

## API Endpoints

### Health Check
- `GET /health` - Service health status
- `GET /api/v1/external/health` - External API health
- `GET /api/v1/internal/health` - Internal API health

## Environment Variables

See `.env.example` for all available configuration options.

## License

ISC