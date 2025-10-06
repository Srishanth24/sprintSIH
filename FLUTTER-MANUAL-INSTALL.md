# Manual Flutter Installation Steps (Most Reliable)

Since the automated download is having network issues, here's the manual approach:

## Step 1: Download Flutter SDK Manually

1. Open your web browser
2. Go to: https://docs.flutter.dev/get-started/install/windows
3. Click "Download Flutter SDK" (latest stable version)
4. Save the zip file to your Downloads folder

## Step 2: Extract Flutter

1. Extract the downloaded zip file to `C:\` (so you have `C:\flutter\`)
2. Make sure the folder structure is: `C:\flutter\bin\flutter.bat`

## Step 3: Add Flutter to PATH (Choose one method)

### Method A: Using PowerShell (Run as Administrator)

```powershell
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\flutter\bin", "User")
```

### Method B: Using System Settings (GUI)

1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Click "Environment Variables"
3. Under "User variables", find "Path" and click "Edit"
4. Click "New" and add: `C:\flutter\bin`
5. Click OK to save all dialogs

## Step 4: Verify Installation

1. **Restart PowerShell/Command Prompt** (important!)
2. Run these commands:

```bash
flutter --version
flutter doctor
```

## Step 5: Install Dependencies (if needed)

Based on `flutter doctor` output, you may need:

### Android Studio (for Android development)

1. Download from: https://developer.android.com/studio
2. Install with default settings
3. Run: `flutter doctor --android-licenses` (accept all)

### Visual Studio (for Windows development)

1. Download Visual Studio Community
2. Install with "Desktop development with C++" workload

## Step 6: Setup Project

Once Flutter is working:

```bash
cd "d:\Hackathon\New co\frontend"
flutter pub get
flutter devices
flutter run
```

## Quick Test Commands

```bash
# Check Flutter is installed
flutter --version

# Check what's missing
flutter doctor

# List available devices
flutter devices

# Run the app
cd frontend
flutter run
```

## Troubleshooting

- **"flutter is not recognized"** → Restart terminal after adding to PATH
- **Android licenses** → Run `flutter doctor --android-licenses`
- **No devices** → Start Android emulator or connect phone with USB debugging

The key is restarting your terminal after adding Flutter to PATH!
