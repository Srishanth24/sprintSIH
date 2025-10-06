#!/bin/bash

echo "========================================"
echo " Starting Hackathon App Services"
echo "========================================"
echo

echo "Starting Backend Server..."
cd backend
npm start &
BACKEND_PID=$!
cd ..

echo "Starting ML Service..."
cd ml_service
python main.py &
ML_PID=$!
cd ..

echo
echo "Services are starting..."
echo
echo "Backend: http://localhost:3000"
echo "ML Service: http://localhost:8000"
echo
echo "To start the Flutter app:"
echo "  cd frontend"
echo "  flutter run"
echo
echo "Demo credentials:"
echo "  Email: demo@demo.com"
echo "  Password: demo123"
echo
echo "Press Ctrl+C to stop all services"

# Wait for interrupt
trap "kill $BACKEND_PID $ML_PID; exit" INT
wait