@echo off
echo ========================================
echo  Starting Hackathon App Services
echo ========================================
echo.

echo Starting Backend Server...
start "Backend Server" cmd /c "cd backend && npm start"
timeout /t 2 >nul

echo Starting ML Service...
start "ML Service" cmd /c "cd ml_service && python main.py"
timeout /t 2 >nul

echo.
echo Services are starting...
echo.
echo Backend: http://localhost:3000
echo ML Service: http://localhost:8000
echo.
echo To start the Flutter app:
echo   cd frontend
echo   flutter run
echo.
echo Demo credentials:
echo   Email: demo@demo.com  
echo   Password: demo123
echo.
echo Press any key to close this window...
pause >nul