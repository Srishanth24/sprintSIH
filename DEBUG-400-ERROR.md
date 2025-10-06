# 🚨 Quick Fix for 400 Bad Request Error

## Problem Diagnosis

The 400 Bad Request error usually means:

1. **Database not set up** (most common)
2. **Backend connection issues**
3. **Invalid request format**

## Step-by-Step Fix

### Step 1: Database Setup (Critical!)

**Option A: If you have PostgreSQL installed**

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE hackathon;

# Exit
\q

# Load schema
psql -U postgres -d hackathon -f "d:\Hackathon\New co\database\schema.sql"
```

**Option B: No PostgreSQL? Use SQLite (Quick Fix)**
I can modify the backend to use SQLite instead of PostgreSQL for immediate testing.

### Step 2: Restart Backend Clean

```bash
# Kill any running processes
taskkill /F /IM node.exe

# Start fresh
cd "d:\Hackathon\New co\backend"
npm start
```

### Step 3: Test Backend Health

Open browser: http://localhost:3003/api/health

Should show:

```json
{ "status": "OK", "database": "Connected", "timestamp": "..." }
```

### Step 4: Test Login

```bash
# Test with demo credentials
curl -X POST http://localhost:3003/api/login -H "Content-Type: application/json" -d "{\"email\":\"demo@demo.com\",\"password\":\"demo123\"}"
```

## Quick Alternative: SQLite Version

If PostgreSQL setup is too complex, I can create a SQLite version that works immediately without external database setup.

Would you like me to:

1. **Help set up PostgreSQL** (recommended)
2. **Create SQLite version** (quick fix)
3. **Debug current setup** step by step

Let me know which approach you prefer!
