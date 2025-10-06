# Backend Setup Instructions

## Prerequisites

- Node.js (v16 or higher)
- PostgreSQL database running

## Quick Setup

1. **Install dependencies:**

   ```bash
   npm install
   ```

2. **Configure environment:**

   - Copy `.env` file and update database connection if needed
   - Default: `postgresql://postgres:postgres@localhost:5432/hackathon`

3. **Start the server:**

   ```bash
   npm start
   ```

   For development with auto-restart:

   ```bash
   npm run dev
   ```

## Environment Variables

- `PORT` - Server port (default: 3000)
- `JWT_SECRET` - Secret key for JWT tokens
- `DATABASE_URL` - PostgreSQL connection string

## API Endpoints

- `POST /api/signup` - User registration
- `POST /api/login` - User authentication
- `GET /api/dashboard` - User dashboard data
- `GET /api/records` - User records
- `POST /api/records` - Create record
- `PUT /api/records/:id` - Update record
- `DELETE /api/records/:id` - Delete record
- `POST /api/upload` - File upload with ML analysis

## Testing

Use demo credentials:

- Email: demo@demo.com
- Password: demo123

Server will run on http://localhost:3000
