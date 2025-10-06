# PostgreSQL Setup Commands

# After installing PostgreSQL, run these commands:

# Step 1: Create the database
psql -U postgres -c "CREATE DATABASE hackathon;"

# Step 2: Load the schema and data
psql -U postgres -d hackathon -f "d:\Hackathon\New co\database\schema.sql"

# Step 3: Verify setup
psql -U postgres -d hackathon -c "SELECT * FROM users;"

# Expected output: Should show the demo user (demo@demo.com)