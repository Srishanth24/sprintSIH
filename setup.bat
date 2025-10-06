@echo off
echo ========================================
echo  Hackathon App Setup Script
echo ========================================
echo.

echo [1/4] Setting up Backend...
cd backend
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Backend setup failed
    pause
    exit /b 1
)
echo Backend setup complete!
echo.

echo [2/4] Setting up ML Service...
cd ..\ml_service
call pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: ML Service setup failed
    pause
    exit /b 1
)
echo ML Service setup complete!
echo.

echo [3/4] Setting up Database...
echo Please ensure PostgreSQL is running and execute:
echo   psql -U postgres
echo   CREATE DATABASE hackathon;
echo   \q
echo   psql -U postgres -d hackathon -f database/schema.sql
echo.

echo [4/4] Setting up Frontend...
cd ..\frontend
echo Please ensure Flutter SDK is installed, then run:
echo   flutter pub get
echo   flutter run
echo.

echo ========================================
echo  Setup Instructions Summary
echo ========================================
echo.
echo 1. Complete database setup (see above)
echo 2. Start backend: cd backend && npm start
echo 3. Start ML service: cd ml_service && python main.py
echo 4. Start frontend: cd frontend && flutter run
echo.
echo Demo credentials:
echo   Email: demo@demo.com
echo   Password: demo123
echo.
echo ========================================
pause