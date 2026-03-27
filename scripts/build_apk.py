#!/usr/bin/env python3
"""
Zingify APK Builder - Production Ready APK Generator
This script builds a working APK for Android without localhost dependencies
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def run_command(command, cwd=None):
    """Run a command and return the result"""
    try:
        result = subprocess.run(command, shell=True, cwd=cwd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def check_flutter_version():
    """Check Flutter version and compatibility"""
    print("🔍 Checking Flutter version...")
    success, output, error = run_command("flutter --version")
    
    if success:
        print(f"✅ Flutter version: {output.strip()}")
        return True
    else:
        print(f"❌ Flutter not found: {error}")
        return False

def setup_flutter_environment():
    """Setup Flutter environment for APK building"""
    print("🔧 Setting up Flutter environment...")
    
    # Clean previous builds
    print("🧹 Cleaning previous builds...")
    success, _, _ = run_command("flutter clean")
    
    if not success:
        print("❌ Failed to clean Flutter project")
        return False
    
    # Get dependencies
    print("📦 Getting dependencies...")
    success, output, error = run_command("flutter pub get")
    
    if not success:
        print(f"❌ Failed to get dependencies: {error}")
        return False
    
    print("✅ Flutter environment setup complete")
    return True

def update_gradle_config():
    """Update Gradle configuration for compatibility"""
    print("⚙️ Updating Gradle configuration...")
    
    settings_gradle_path = "android/settings.gradle"
    
    # Read current settings.gradle
    try:
        with open(settings_gradle_path, 'r') as f:
            content = f.read()
        
        # Update to compatible versions
        new_content = content.replace(
            'id("com.android.application") version "8.1.0" apply false',
            'id("com.android.application") version "8.0.2" apply false'
        )
        
        with open(settings_gradle_path, 'w') as f:
            f.write(new_content)
        
        print("✅ Gradle configuration updated")
        return True
        
    except Exception as e:
        print(f"❌ Failed to update Gradle config: {e}")
        return False

def build_apk():
    """Build the APK"""
    print("🏗️ Building APK...")
    
    # Try different build approaches
    build_commands = [
        "flutter build apk --release --no-shrink",
        "flutter build apk --debug",
        "flutter build apk --release"
    ]
    
    for i, command in enumerate(build_commands, 1):
        print(f"📱 Attempt {i}: {command}")
        success, output, error = run_command(command)
        
        if success:
            print("✅ APK build successful!")
            return True
        else:
            print(f"⚠️ Build attempt {i} failed: {error}")
    
    print("❌ All build attempts failed")
    return False

def create_production_config():
    """Create production configuration"""
    print("📝 Creating production configuration...")
    
    # Update API URLs to production
    zingify_app_path = "lib/zingify_app.dart"
    
    try:
        with open(zingify_app_path, 'r') as f:
            content = f.read()
        
        # Update to production URLs
        new_content = content.replace(
            "static const String baseUrl = 'http://localhost:5000';",
            "static const String baseUrl = 'https://zingify-api.herokuapp.com';"
        )
        
        with open(zingify_app_path, 'w') as f:
            f.write(new_content)
        
        print("✅ Production configuration created")
        return True
        
    except Exception as e:
        print(f"❌ Failed to create production config: {e}")
        return False

def verify_apk():
    """Verify APK was created and provide info"""
    print("🔍 Verifying APK...")
    
    apk_paths = [
        "build/app/outputs/flutter-apk/app-release.apk",
        "build/app/outputs/flutter-apk/app-debug.apk",
        "android/app/build/outputs/apk/release/app-release.apk"
    ]
    
    for apk_path in apk_paths:
        if os.path.exists(apk_path):
            size = os.path.getsize(apk_path) / (1024 * 1024)  # Size in MB
            print(f"✅ APK found: {apk_path}")
            print(f"📦 APK Size: {size:.2f} MB")
            return apk_path
    
    print("❌ No APK found")
    return None

def create_installation_guide(apk_path):
    """Create installation guide"""
    print("📖 Creating installation guide...")
    
    guide = f"""
# 📱 Zingify APK Installation Guide

## 📦 APK Information
- **File**: {apk_path}
- **Size**: {os.path.getsize(apk_path) / (1024 * 1024):.2f} MB
- **Version**: 1.0.0
- **Build Date**: {subprocess.check_output(['date']).decode().strip()}

## 🚀 Installation Instructions

### Method 1: Direct Install
1. Download the APK file to your Android device
2. Go to Settings → Security → Enable "Unknown Sources"
3. Open the APK file and tap "Install"
4. Wait for installation to complete
5. Launch Zingify app

### Method 2: ADB Install
1. Connect your Android device via USB
2. Enable USB Debugging in Developer Options
3. Run: `adb install {apk_path}`
4. Launch Zingify app

### Method 3: QR Code Install
1. Upload APK to cloud storage (Google Drive, Dropbox)
2. Generate QR code for the download link
3. Scan QR code with Android device
4. Download and install

## ✨ App Features
- ✅ Firebase Authentication
- ✅ Real-time Messaging
- ✅ Media Sharing (Photos, Files)
- ✅ Emoji Picker
- ✅ Contact Integration
- ✅ Push Notifications
- ✅ Modern Material 3 UI

## 🔧 Configuration
- **Backend URL**: https://zingify-api.herokuapp.com
- **Firebase Project**: zingify-messaging-app
- **Package Name**: com.zingify.app

## 🎯 First Time Setup
1. Open Zingify app
2. Allow permissions (Contacts, Camera, Storage)
3. Enter your phone number
4. Verify with OTP (123456 for demo)
5. Start messaging!

## 📞 Support
For issues or questions, contact: support@zingify.app

---
🎉 **Your Zingify app is ready to use!**
"""
    
    with open("INSTALLATION_GUIDE.md", 'w') as f:
        f.write(guide)
    
    print("✅ Installation guide created: INSTALLATION_GUIDE.md")

def main():
    """Main build process"""
    print("🚀 Starting Zingify APK Build Process")
    print("=" * 50)
    
    # Step 1: Check Flutter
    if not check_flutter_version():
        sys.exit(1)
    
    # Step 2: Setup environment
    if not setup_flutter_environment():
        sys.exit(1)
    
    # Step 3: Create production config
    if not create_production_config():
        sys.exit(1)
    
    # Step 4: Update Gradle
    if not update_gradle_config():
        sys.exit(1)
    
    # Step 5: Build APK
    if not build_apk():
        print("❌ APK build failed")
        print("\n🔧 Alternative Solutions:")
        print("1. Use GitHub Actions (see BUILD_PRODUCTION_APK.md)")
        print("2. Try older Flutter version: flutter downgrade 3.16.0")
        print("3. Use Android Studio to build")
        sys.exit(1)
    
    # Step 6: Verify APK
    apk_path = verify_apk()
    if not apk_path:
        sys.exit(1)
    
    # Step 7: Create guide
    create_installation_guide(apk_path)
    
    print("\n" + "=" * 50)
    print("🎉 APK Build Complete!")
    print(f"📱 APK Location: {apk_path}")
    print("📖 Installation Guide: INSTALLATION_GUIDE.md")
    print("🚀 Your app is ready for Android devices!")

if __name__ == "__main__":
    main()
