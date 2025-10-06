#!/bin/bash

echo "========================================"
echo " Hackathon App Setup Script"
echo "========================================"
echo

echo "[1/4] Setting up Backend..."
cd backend
npm install
if [ $? -ne 0 ]; then
    echo "ERROR: Backend setup failed"
    exit 1
fi
echo "Backend setup complete!"
echo

echo "[2/4] Setting up ML Service..."
cd ../ml_service
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "ERROR: ML Service setup failed"
    exit 1
fi
echo "ML Service setup complete!"
echo

echo "[3/4] Setting up Database..."
echo "Please ensure PostgreSQL is running and execute:"
echo "  psql -U postgres"
echo "  CREATE DATABASE hackathon;"
echo "  \\q"
echo "  psql -U postgres -d hackathon -f database/schema.sql"
echo

echo "[4/4] Setting up Frontend..."
cd ../frontend
echo "Please ensure Flutter SDK is installed, then run:"
echo "  flutter pub get"
echo "  flutter run"
echo

echo "========================================"
echo " Setup Instructions Summary"
echo "========================================"
echo
echo "1. Complete database setup (see above)"
echo "2. Start backend: cd backend && npm start"
echo "3. Start ML service: cd ml_service && python main.py"  
echo "4. Start frontend: cd frontend && flutter run"
echo
echo "Demo credentials:"
echo "  Email: demo@demo.com"
echo "  Password: demo123"
echo
echo "========================================"