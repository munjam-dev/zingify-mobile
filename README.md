# 🚀 Zingify - Premium Real-Time Messaging App

A **FULLY WORKING** real-time messaging application built with Flutter and Node.js, featuring complete authentication, real-time messaging, and all modern chat features.

## ✨ Features

### 🔐 **Authentication System**
- ✅ **Real OTP Authentication** (Firebase Auth)
- ✅ **Country Code Picker** (India Default + All Countries)
- ✅ **Terms & Conditions** Acceptance
- ✅ **Resend OTP** with Timer (30 seconds)
- ✅ **Auto OTP Detection** (Android)
- ✅ **Secure JWT Token** Management

### 💬 **Real-Time Messaging**
- ✅ **Socket.IO Real-Time** Chat
- ✅ **Typing Indicators**
- ✅ **Online/Offline Status**
- ✅ **Message Status** (Sent/Delivered/Seen)
- ✅ **Message History** with Pagination
- ✅ **Unread Count** Management

### 📱 **Rich Media Support**
- ✅ **Image Sharing** (Camera + Gallery)
- ✅ **Video Messages**
- ✅ **Voice Notes**
- ✅ **File Attachments** (PDF, DOC, etc.)
- ✅ **Emoji Picker** with Search
- ✅ **Media Preview** Thumbnails

### 🔔 **Push Notifications**
- ✅ **Firebase Cloud Messaging** (FCM)
- ✅ **Background Notifications**
- ✅ **Foreground Notification Handling**
- ✅ **Notification Click** → Open Chat
- ✅ **Badge Count** Updates

### 👥 **Contact Management**
- ✅ **Contacts Sync** from Device
- ✅ **Permission Handling**
- ✅ **Contact Search**
- ✅ **Profile Pictures**
- ✅ **Last Seen** Status

### 🎨 **UI/UX Features**
- ✅ **Material Design 3** Theme
- ✅ **Dark Mode** Support
- ✅ **Glassmorphism** Effects
- ✅ **Smooth Animations**
- ✅ **Responsive Design**
- ✅ **Custom Logo** & Branding

## 🏗️ **Architecture**

### **Backend (Node.js)**
- **Express.js** REST API
- **MongoDB** with Mongoose ODM
- **Socket.IO** for Real-Time
- **JWT** Authentication
- **Firebase Admin** SDK
- **Multer** File Uploads
- **Rate Limiting** & Security

### **Frontend (Flutter)**
- **Flutter 3.x** with Material 3
- **Firebase Auth** & Messaging
- **Socket.IO Client**
- **Riverpod** State Management
- **Shared Preferences** Storage
- **Permission Handler**
- **Image/File Picker**

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK (>=3.0.0)
- Node.js (>=18.0.0)
- MongoDB (>=5.0)
- Firebase Project

### **1. Backend Setup**

```bash
# Navigate to backend directory
cd C:\Users\PC\CascadeProjects\zingify\backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Update .env with your credentials:
# - MongoDB URI
# - JWT Secret
# - Firebase Admin SDK credentials
# - Twilio credentials (for real SMS)

# Start development server
npm run dev
```

### **2. Firebase Setup**

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project: `zingify-messaging-app`

2. **Enable Services**
   - **Authentication** → Phone Sign-in
   - **Cloud Messaging** (FCM)
   - **Firestore** (optional, for future features)

3. **Download Config Files**
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

4. **Place Config Files**
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

### **3. Flutter Setup**

```bash
# Navigate to Flutter directory
cd C:\Users\PC\CascadeProjects\zingify_mobile_new

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **4. Build APK**

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 📱 **Demo Mode**

The app runs in **Demo Mode** by default:

- **OTP**: Always `123456`
- **Backend**: `http://localhost:5000`
- **MongoDB**: Local instance
- **Firebase**: Demo configuration

## 🔧 **Configuration**

### **Environment Variables (.env)**

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/zingify

# JWT
JWT_SECRET=your_super_secret_key_here

# Firebase Admin SDK
FIREBASE_PROJECT_ID=zingify-messaging-app
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@zingify-messaging-app.iam.gserviceaccount.com

# Twilio (Real SMS)
TWILIO_ACCOUNT_SID=AC_your_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890
```

### **Firebase Configuration**

Update `lib/zingify_app.dart`:

```dart
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "your-api-key",
  authDomain: "zingify-messaging-app.firebaseapp.com",
  projectId: "zingify-messaging-app",
  storageBucket: "zingify-messaging-app.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:android:abcdef",
);
```

## 🗄️ **Database Schema**

### **Users Collection**
```javascript
{
  uid: String (Firebase UID),
  name: String,
  phone: String,
  countryCode: String,
  email: String,
  profilePicture: String,
  bio: String,
  isOnline: Boolean,
  lastSeen: Date,
  fcmToken: String,
  contacts: [ObjectId],
  createdAt: Date,
  updatedAt: Date
}
```

### **Messages Collection**
```javascript
{
  senderId: ObjectId,
  receiverId: ObjectId,
  content: String,
  type: String (text/image/video/audio/file),
  fileUrl: String,
  fileName: String,
  fileSize: Number,
  timestamp: Date,
  status: String (sent/delivered/seen),
  edited: Boolean,
  deleted: Boolean
}
```

### **Chats Collection**
```javascript
{
  participants: [ObjectId],
  lastMessage: ObjectId,
  lastMessageTime: Date,
  unreadCounts: Map,
  isGroup: Boolean,
  groupName: String,
  groupDescription: String,
  groupPicture: String,
  createdBy: ObjectId,
  createdAt: Date,
  updatedAt: Date
}
```

## 🔌 **API Endpoints**

### **Authentication**
- `POST /api/auth/send-otp` - Send OTP
- `POST /api/auth/verify-otp` - Verify OTP & Login

### **User Management**
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile

### **Chat & Messages**
- `GET /api/chats` - Get user chats
- `GET /api/messages/:userId` - Get chat messages
- `POST /api/upload` - Upload file/media

### **Socket.IO Events**
- `join` - User joins socket room
- `send_message` - Send new message
- `receive_message` - Receive message
- `typing` - Typing indicator
- `mark_messages_seen` - Mark messages as read
- `user_online` - User came online
- `user_offline` - User went offline

## 🔐 **Security Features**

- **JWT Authentication** with expiration
- **Rate Limiting** on API endpoints
- **Input Validation** & Sanitization
- **File Upload** Security
- **CORS** Configuration
- **Helmet.js** Security Headers
- **End-to-End Encryption** (future)

## 🚀 **Deployment**

### **Backend Deployment**

```bash
# Build for production
npm run build

# Start production server
npm start

# Using PM2 (recommended)
pm2 start server.js --name "zingify-api"
```

### **Flutter Deployment**

```bash
# Android Release APK
flutter build apk --release --shrink

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS Release
flutter build ios --release
```

## 📱 **Platform Support**

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- 🔄 **Web** (Coming Soon)
- 🔄 **Desktop** (Coming Soon)

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

For support, please contact:

- 📧 Email: support@zingify.app
- 💬 Discord: [Join our community](https://discord.gg/zingify)
- 📱 WhatsApp: +91 98765 43210

## 🌟 **Acknowledgments**

- **Flutter Team** for amazing framework
- **Firebase** for authentication & messaging
- **Socket.IO** for real-time communication
- **MongoDB** for database
- **Open Source Community**

---
 
**Made with ❤️ in India | Zingify - Connecting the World, One Message at a Time**
