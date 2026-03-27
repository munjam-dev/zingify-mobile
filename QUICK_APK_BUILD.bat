@echo off
echo 🚀 Zingify APK Builder - Quick Build Script
echo ========================================

echo 📱 Step 1: Clean previous builds...
flutter clean

echo 📦 Step 2: Get dependencies...
flutter pub get

echo ⚙️ Step 3: Update production config...
powershell -Command "(Get-Content lib\zingify_app.dart) -replace 'http://localhost:5000', 'https://zingify-api.herokuapp.com' | Set-Content lib\zingify_app.dart"

echo 🏗️ Step 4: Build APK...
flutter build apk --release --no-shrink

echo 🔍 Step 5: Check APK...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK Build Successful!
    echo 📦 APK Location: build\app\outputs\flutter-apk\app-release.apk
    
    for %%I in ("build\app\outputs\flutter-apk\app-release.apk") do echo 📊 APK Size: %%~zI bytes
    
    echo 🎉 Your Zingify APK is ready!
    echo 📖 See INSTALLATION_GUIDE.md for installation instructions
) else (
    echo ❌ APK Build Failed
    echo 🔧 Try alternative solutions in BUILD_PRODUCTION_APK.md
)

pause
