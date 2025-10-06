# Database Setup Instructions

## Prerequisites

- PostgreSQL installed and running
- psql command line tool

## Quick Setup

1. **Create database:**

   ```bash
   psql -U postgres
   CREATE DATABASE hackathon;
   \q
   ```

2. **Run schema:**
   ```bash
   psql -U postgres -d hackathon -f schema.sql
   ```

## Database Schema

### Tables

- **users** - User accounts with authentication

  - id, email, password_hash, name, created_at

- **uploads** - File upload metadata

  - id, user_id, filename, filetype, metadata, uploaded_at

- **records** - User records for CRUD operations
  - id, user_id, title, data, created_at

### Relationships

- users → uploads (one-to-many)
- users → records (one-to-many)

## Demo Data

The schema includes demo data:

- Demo user: demo@demo.com / demo123
- Sample records for testing analytics

## Configuration

Update the database connection in your backend `.env` file:

```
DATABASE_URL=postgresql://username:password@localhost:5432/hackathon
```

## Backup/Restore

Backup:

```bash
pg_dump -U postgres hackathon > backup.sql
```

Restore:

```bash
psql -U postgres -d hackathon < backup.sql
```
