# Manual Flutter Installation Commands

# Step 1: Download Flutter SDK
Write-Host "1. Download Flutter SDK..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip" -OutFile "$env:TEMP\flutter.zip"

# Step 2: Extract to C:\flutter
Write-Host "2. Extracting..." -ForegroundColor Yellow
Expand-Archive -Path "$env:TEMP\flutter.zip" -DestinationPath "C:\" -Force

# Step 3: Add to PATH
Write-Host "3. Adding to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$currentPath;C:\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# Step 4: Refresh current session
$env:Path = "$env:Path;C:\flutter\bin"

Write-Host "Installation complete! Restart PowerShell and run: flutter doctor" -ForegroundColor Green