# 📱 ANDROID STUDIO SETUP GUIDE

## 🔧 **STEP-BY-STEP SETUP**

### **Step 1: Install Android Studio**
1. Download Android Studio from: https://developer.android.com/studio
2. Run the installer and follow the setup wizard
3. Choose "Standard" installation when prompted

### **Step 2: Configure Android SDK**
1. Open Android Studio
2. Go to **File → Settings → Appearance & Behavior → System Settings → Android SDK**
3. Click **Edit** next to Android SDK Location
4. Set SDK path to: `C:\Users\PC\AppData\Local\Android\Sdk`
5. Click **OK**

### **Step 3: Install Required SDK Components**
1. In Android Studio, go to **Tools → SDK Manager**
2. Select the **SDK Platforms** tab
3. Check these packages:
   - ✅ Android 14.0 (API Level 34)
   - ✅ Android 13.0 (API Level 33)
   - ✅ Android 12.0 (API Level 32)
4. Select the **SDK Tools** tab
5. Check these packages:
   - ✅ Android SDK Build-Tools 34.0.0
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Tools
   - ✅ Google Play services
   - ✅ Android Emulator
6. Click **Apply** → **OK** to install

### **Step 4: Set Environment Variables**
1. Press **Windows + R**, type `sysdm.cpl`, press Enter
2. Go to **Advanced** tab → **Environment Variables**
3. Under **System variables**:
   - Click **New** → Variable name: `ANDROID_HOME`
   - Variable value: `C:\Users\PC\AppData\Local\Android\Sdk`
4. Find **Path** variable → **Edit** → **New**
5. Add these paths:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
   - `%ANDROID_HOME%\tools\bin`
6. Click **OK** on all windows

### **Step 5: Accept Android SDK Licenses**
1. Open **Command Prompt** as Administrator
2. Navigate to Android SDK tools:
   ```cmd
   cd C:\Users\PC\AppData\Local\Android\Sdk\tools\bin
   ```
3. Run:
   ```cmd
   sdkmanager --licenses
   ```
4. Type `y` and press Enter for all licenses
5. Alternatively, run:
   ```cmd
   flutter doctor --android-licenses
   ```

### **Step 6: Open Zingify Project in Android Studio**
1. Open Android Studio
2. Click **Open** (or File → Open)
3. Navigate to: `C:\Users\PC\CascadeProjects\zingify_mobile_new`
4. Select the folder and click **OK**
5. Wait for Gradle sync to complete (may take several minutes)

### **Step 7: Configure Virtual Device**
1. In Android Studio, go to **Tools → Device Manager**
2. Click **Create Device**
3. Choose **Phone** → **Pixel 6** (or any Pixel device)
4. Select **API Level 34** (Android 14.0)
5. Click **Next**
6. Select **Play Store Image**
7. Click **Next** → **Finish**
8. Wait for download to complete

### **Step 8: Run the App**
#### **Method 1: Using Android Studio**
1. Select your virtual device from the dropdown menu
2. Click the **Run** button (green play icon)
3. Wait for build and installation

#### **Method 2: Using Flutter CLI**
1. Open Command Prompt in project directory:
   ```cmd
   cd C:\Users\PC\CascadeProjects\zingify_mobile_new
   ```
2. Run:
   ```cmd
   flutter run
   ```
3. Select your device from the list

## 🔧 **TROUBLESHOOTING**

### **Issue: Gradle Sync Failed**
1. **Solution 1:** Check internet connection
2. **Solution 2:** Clear Gradle cache:
   ```cmd
   cd android
   gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```
3. **Solution 3:** Update Gradle wrapper:
   ```cmd
   cd android
   gradlew wrapper --gradle-version 8.0
   ```

### **Issue: SDK Not Found**
1. Verify ANDROID_HOME environment variable
2. Restart Android Studio
3. Check SDK Manager for installed packages

### **Issue: Emulator Not Starting**
1. Enable Windows Hypervisor Platform:
   - Turn Windows features on/off
   - Check "Windows Hypervisor Platform"
2. Enable Virtualization in BIOS
3. Restart computer

### **Issue: Build Errors**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Android Studio's Build tab for specific errors

## 📱 **PHYSICAL DEVICE SETUP**

### **Step 1: Enable Developer Options**
1. Go to **Settings → About phone**
2. Tap **Build number** 7 times
3. "You are now a developer!" message appears

### **Step 2: Enable USB Debugging**
1. Go to **Settings → Developer options**
2. Enable **USB debugging**
3. Enable **USB debugging (security settings)**

### **Step 3: Connect Device**
1. Connect phone to PC via USB
2. Allow USB debugging when prompted
3. Run:
   ```cmd
   flutter devices
   ```
4. Select your device when running the app

## ✅ **VERIFICATION**

Run these commands to verify setup:
```cmd
# Check Flutter doctor
flutter doctor

# Check connected devices
flutter devices

# Check Android SDK
flutter doctor -v

# Test build
flutter build apk --debug
```

## 🎯 **NEXT STEPS**

1. **Firebase Setup:**
   - Create Firebase project at `zingify-messaging-app`
   - Download `google-services.json`
   - Replace in `android/app/google-services.json`

2. **Backend Setup:**
   - Install Node.js and MongoDB
   - Run backend server on `localhost:5000`

3. **Testing:**
   - Test OTP verification
   - Test real-time messaging
   - Test push notifications

Your Zingify app should now run successfully in Android Studio! 🚀
