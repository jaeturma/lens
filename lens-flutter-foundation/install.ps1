param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$mobileRoot = Join-Path $ProjectRoot 'mobile'
$templateMobile = Join-Path $PSScriptRoot 'mobile-template'
$templateRoot = Join-Path $PSScriptRoot 'root-template'

if (-not (Test-Path (Join-Path $ProjectRoot 'artisan'))) {
    throw "Laravel project root not found at: $ProjectRoot"
}

if (-not (Test-Path (Join-Path $mobileRoot 'pubspec.yaml'))) {
    throw "Flutter project not found at: $mobileRoot"
}

Write-Host "LENS Flutter Foundation Installer" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"
Write-Host "Flutter root: $mobileRoot"

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $mobileRoot "_foundation_backup_$timestamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

foreach ($relativePath in @('lib', 'test')) {
    $source = Join-Path $mobileRoot $relativePath
    if (Test-Path $source) {
        Copy-Item $source (Join-Path $backupRoot $relativePath) -Recurse -Force
    }
}

Write-Host "Backup created: $backupRoot" -ForegroundColor Green

Push-Location $mobileRoot
try {
    Write-Host "Adding minimal dependencies..." -ForegroundColor Cyan
    flutter pub add flutter_riverpod:^3.3.2
    flutter pub add go_router:^17.3.0
    flutter pub add dio
    flutter pub add flutter_secure_storage:^10.3.1

    Write-Host "Installing foundation files..." -ForegroundColor Cyan
    Copy-Item (Join-Path $templateMobile '*') $mobileRoot -Recurse -Force
    Copy-Item (Join-Path $templateRoot '*') $ProjectRoot -Recurse -Force

    dart format lib test
    flutter pub get
    flutter analyze
    flutter test
}
finally {
    Pop-Location
}

Write-Host "" 
Write-Host "Foundation installed successfully." -ForegroundColor Green
Write-Host "Next: start your emulator, then run:" -ForegroundColor Yellow
Write-Host "  cd $mobileRoot"
Write-Host "  flutter run"
