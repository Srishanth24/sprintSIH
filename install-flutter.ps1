# Flutter SDK Auto-Installer for Windows
# Run with: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; .\install-flutter.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Flutter SDK Auto-Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host

# Set variables
$flutterPath = "C:\flutter"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip"
$zipPath = "$env:TEMP\flutter_windows.zip"

# Check if Flutter is already installed
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "✓ Flutter is already installed!" -ForegroundColor Green
    flutter --version
    Write-Host
    Write-Host "Continuing to project setup..." -ForegroundColor Yellow
    
    # Navigate to frontend and install dependencies
    Set-Location "frontend"
    Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
    
    Write-Host
    Write-Host "Flutter setup complete! You can now run:" -ForegroundColor Green
    Write-Host "  flutter run" -ForegroundColor White
    exit 0
}

Write-Host "Step 1: Downloading Flutter SDK..." -ForegroundColor Yellow
Write-Host "This may take a few minutes depending on your internet connection." -ForegroundColor Gray

try {
    # Download Flutter SDK
    Invoke-WebRequest -Uri $flutterUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "✓ Download completed!" -ForegroundColor Green
} catch {
    Write-Host "✗ Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

Write-Host
Write-Host "Step 2: Extracting Flutter SDK..." -ForegroundColor Yellow

try {
    # Create flutter directory if it doesn't exist
    if (!(Test-Path $flutterPath)) {
        New-Item -ItemType Directory -Path $flutterPath -Force | Out-Null
    }
    
    # Extract Flutter SDK
    Expand-Archive -Path $zipPath -DestinationPath "C:\" -Force
    Write-Host "✓ Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "✗ Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please extract manually to C:\flutter" -ForegroundColor Yellow
    exit 1
}

Write-Host
Write-Host "Step 3: Adding Flutter to PATH..." -ForegroundColor Yellow

try {
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if Flutter is already in PATH
    if ($currentPath -notlike "*$flutterPath\bin*") {
        # Add Flutter to PATH
        $newPath = "$currentPath;$flutterPath\bin"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "✓ Flutter added to PATH!" -ForegroundColor Green
        
        # Update current session PATH
        $env:Path = "$env:Path;$flutterPath\bin"
    } else {
        Write-Host "✓ Flutter already in PATH!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Failed to update PATH: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please add C:\flutter\bin to your PATH manually" -ForegroundColor Yellow
}

Write-Host
Write-Host "Step 4: Cleaning up..." -ForegroundColor Yellow
Remove-Item $zipPath -ErrorAction SilentlyContinue

Write-Host
Write-Host "Step 5: Verifying installation..." -ForegroundColor Yellow

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

try {
    # Test Flutter installation
    $flutterVersion = & "$flutterPath\bin\flutter.bat" --version 2>&1
    Write-Host "✓ Flutter installed successfully!" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor Gray
} catch {
    Write-Host "✗ Flutter installation verification failed" -ForegroundColor Red
    Write-Host "Please restart your terminal and try: flutter --version" -ForegroundColor Yellow
}

Write-Host
Write-Host "Step 6: Setting up project dependencies..." -ForegroundColor Yellow

# Navigate to frontend directory and install dependencies
Set-Location "frontend"
try {
    & "$flutterPath\bin\flutter.bat" pub get
    Write-Host "✓ Flutter dependencies installed!" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
    Write-Host "Please run manually: cd frontend; flutter pub get" -ForegroundColor Yellow
}

Write-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Restart your terminal/PowerShell" -ForegroundColor White
Write-Host "2. Run: flutter doctor" -ForegroundColor White
Write-Host "3. Install Android Studio if needed" -ForegroundColor White
Write-Host "4. Run: flutter run (in frontend directory)" -ForegroundColor White
Write-Host
Write-Host "For troubleshooting, see: FLUTTER-INSTALL.md" -ForegroundColor Yellow

# Clean up and return to project root
Set-Location ".."

Write-Host
Write-Host "Press any key to continue..." -ForegroundColor Gray
Read-Host
