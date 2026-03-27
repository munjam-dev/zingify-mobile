@echo off
echo 🚀 Zingify APK Online Build Script
echo =====================================

echo 📱 Step 1: Clean Flutter project...
flutter clean

echo 📦 Step 2: Get dependencies...
flutter pub get

echo 🌐 Step 3: Build for web (fallback)...
flutter build web

echo 📊 Step 4: Check build status...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK Build Successful!
    echo 📦 APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo 🎉 Your Zingify APK is ready!
) else (
    echo ❌ APK Build Failed
    echo 🔧 Try alternative methods:
    echo    1. Codemagic (codemagic.io)
    echo    2. AppCenter (appcenter.ms)
    echo    3. Bitrise (bitrise.io)
    echo    4. GitLab CI/CD
    echo 📖 See ALTERNATIVE_BUILD_METHODS.md for details
)

echo 🌐 Web build available at: build\web\
echo 📱 Use PWA Builder to convert web to APK if needed

pause
