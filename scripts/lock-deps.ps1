# Lock dependencies (Windows PowerShell)
# Runs `flutter pub get` in each package and leaves `pubspec.lock` files updated.

$packages = @(
  "als_study_companion",
  "als_study_companion/mobile_app",
  "als_study_companion/backend_services",
  "als_study_companion/shared_core",
  "als_study_companion/admin_web"
)

foreach ($pkg in $packages) {
  Write-Host "Processing $pkg"
  Push-Location $pkg
  flutter pub get
  Pop-Location
}

Write-Host "Dependency lock completed. Commit pubspec.lock files to lock versions."