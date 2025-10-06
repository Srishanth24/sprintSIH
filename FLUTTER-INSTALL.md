# Flutter Installation Guide for Windows

## Option 1: Automatic Installation (Recommended)

Run the PowerShell script from the main project directory:

```powershell
# Make sure PowerShell execution policy allows scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the installer
.\install-flutter.ps1
```

## Option 2: Manual Installation

### Step 1: Download Flutter SDK

1. Visit: https://docs.flutter.dev/get-started/install/windows
2. Download the latest stable Flutter SDK zip file
3. Extract to `C:\flutter` (recommended location)

### Step 2: Add Flutter to PATH

1. Open System Environment Variables:
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Click "Environment Variables"
2. Under "User variables", find and edit "Path"
3. Add: `C:\flutter\bin`
4. Click OK to save

### Step 3: Verify Installation

Open a new Command Prompt or PowerShell and run:

```bash
flutter doctor
```

### Step 4: Install Dependencies

Flutter doctor will show what's missing. Typically you need:

**Android Studio:**

1. Download from: https://developer.android.com/studio
2. Install with default settings
3. Run: `flutter doctor --android-licenses` and accept all

**Visual Studio (for Windows development):**

1. Download Visual Studio Community
2. Install with "Desktop development with C++" workload

### Step 5: Verify Everything Works

```bash
flutter doctor -v
```

All items should show checkmarks ✓

## Option 3: Using Chocolatey (If you have Chocolatey installed)

```powershell
choco install flutter
```

## After Installation

1. **Restart your terminal/PowerShell**
2. **Navigate to the frontend directory:**
   ```bash
   cd "d:\Hackathon\New co\frontend"
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

## Troubleshooting

### Common Issues:

**"flutter is not recognized"**

- Restart your terminal after adding to PATH
- Make sure `C:\flutter\bin` is in your PATH environment variable

**Android licenses not accepted**

```bash
flutter doctor --android-licenses
```

**VS Code Flutter extension**

- Install Flutter extension in VS Code
- Restart VS Code after Flutter installation

### Check Installation Status

```bash
flutter doctor
flutter --version
```

## Quick Test

Once installed, test with:

```bash
cd "d:\Hackathon\New co\frontend"
flutter doctor
flutter pub get
flutter devices
flutter run
```
