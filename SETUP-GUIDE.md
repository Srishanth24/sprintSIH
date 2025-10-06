# 🚀 Quick Setup Guide - Where to Run Commands

## Overview

All commands should be run from the **main project directory**: `d:\Hackathon\New co\`

## Step-by-Step Setup

### 1. Database Setup (PostgreSQL)

**Location:** Any terminal with PostgreSQL access

```bash
# Open Command Prompt or PowerShell anywhere
psql -U postgres
CREATE DATABASE hackathon;
\q

# Then run this from the main project directory
psql -U postgres -d hackathon -f database/schema.sql
```

### 2. Backend Setup

**Location:** `d:\Hackathon\New co\`

```bash
cd backend
npm install
npm start
```

✅ **This should work** - Node.js dependencies are already installed

### 3. ML Service Setup

**Location:** `d:\Hackathon\New co\`

```bash
cd ml_service
pip install -r requirements.txt
python main.py
```

✅ **This should work** - Python dependencies are already installed

### 4. Frontend Setup (Flutter)

**Location:** `d:\Hackathon\New co\`

**❌ ISSUE:** Flutter SDK is not installed on your system

**SOLUTION:** Install Flutter first:

1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
2. Extract and add to your PATH
3. Then run:

```bash
cd frontend
flutter pub get
flutter run
```

## 🎯 Current Status

- ✅ Backend: Ready to run
- ✅ ML Service: Ready to run
- ✅ Database: Schema created, needs DB setup
- ❌ Frontend: Needs Flutter SDK installation

## 🔧 Quick Start (Without Flutter)

You can test the backend and ML service immediately:

**Terminal 1:**

```bash
cd "d:\Hackathon\New co\backend"
npm start
```

**Terminal 2:**

```bash
cd "d:\Hackathon\New co\ml_service"
python main.py
```

Then visit:

- Backend API: http://localhost:3000
- ML Service docs: http://localhost:8000/docs

## 📱 Alternative: Use Web Version

If you want to test without installing Flutter, I can create a web version using React or vanilla HTML/JS that connects to the same backend APIs.

Would you like me to create a web version for immediate testing?
