# 🚀 Flutter Chat App with Firebase Authentication

A fully functional, production-ready chat application built with Flutter featuring Firebase Authentication, real-time messaging, push notifications, biometric login, and local message persistence.

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![Provider](https://img.shields.io/badge/State-Provider-blue)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite)

## ✨ Features

### 🔐 Complete Authentication System
- **Email/Password Authentication** - Secure Firebase authentication
- **User Registration** - Create new accounts with validation
- **Biometric Login** - Quick access with fingerprint/Face ID
- **Password Reset** - Email-based password recovery
- **Session Persistence** - Stay logged in across app restarts
- **Secure Storage** - Encrypted credential storage

### 💬 Real-time Chat
- **Instant Messaging** - Real-time message delivery with Firebase Firestore
- **Private Conversations** - One-on-one chat between users
- **Message Persistence** - Local SQLite database for offline access
- **Auto Sync** - Messages sync automatically when online
- **Read Receipts** - See when messages are delivered and read
- **Offline Support** - Send and receive messages without internet
- **Beautiful UI** - Modern Material Design 3 with gradient themes

### 🔔 Push Notifications
- **Firebase Cloud Messaging** - Real-time push notifications
- **Background Notifications** - Receive messages when app is closed
- **Foreground Notifications** - In-app notification handling
- **Notification Actions** - Tap to open conversation
- **Custom Sounds** - Configurable notification tones

### 📱 User Management
- **User List Screen** - Browse all registered users
- **Profile Management** - User profiles with avatars
- **Online Status** - Real-time connection indicators
- **Search Users** - Find and start conversations

### 🏗️ Clean Architecture
- **Provider State Management** - Reactive and efficient
- **Service Layer Pattern** - Modular business logic
- **Repository Pattern** - Data abstraction
- **Comprehensive Error Handling** - User-friendly error messages
- **Type-safe Code** - Full Dart type safety

## 🎯 Technical Highlights

### State Management with Provider
- **AuthProvider** - Manages authentication state
- **ChatProvider** - Handles chat operations
- **Reactive UI** - Automatic updates on state changes
- **Efficient Rebuilds** - Only necessary widgets rebuild

### Local Data Persistence
- **SQLite Database** - Efficient message storage
- **Indexed Queries** - Fast message retrieval
- **Database Versioning** - Smooth migrations
- **Offline-first** - App works without internet

### Security Features
✅ Passwords never stored in plain text  
✅ Biometric credentials in secure storage  
✅ Firebase security rules implemented  
✅ Input validation on all forms  
✅ HTTPS-only connections  
✅ Token-based authentication  

## 📋 Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **Firebase Account** - Free tier is sufficient
- **Android Studio / Xcode** - For building native apps
- **Physical Device** - For biometric testing (emulator support varies)

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd hourandmoreflutter
flutter pub get
```

### 2. Configure Firebase

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Your Firebase Project
```bash
flutterfire configure
```

This will:
- Create/select a Firebase project
- Register your app for all platforms
- Generate `firebase_options.dart`
- Download configuration files

### 3. Enable Firebase Services

#### Enable Authentication:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project → Authentication
3. Click "Get Started"
4. Enable "Email/Password" sign-in method

#### Enable Firestore:
1. In Firebase Console → Firestore Database
2. Click "Create Database"
3. Start in **production mode**
4. Choose your location
5. Update security rules (see Configuration section)

#### Enable Cloud Messaging:
1. In Firebase Console → Cloud Messaging
2. No additional setup required
3. FCM is automatically configured

### 4. Set Up Firestore Security Rules

Go to Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read: if request.auth.uid == resource.data.senderId 
                  || request.auth.uid == resource.data.receiverId;
      allow create: if request.auth.uid == request.resource.data.senderId;
      allow delete: if request.auth.uid == resource.data.senderId;
    }
  }
}
```

### 5. Run the App

```bash
# For Android
flutter run

# For iOS (requires macOS)
flutter run -d ios

# For Windows (fastest for testing)
flutter run -d windows
```

## 📁 Project Structure

```
lib/
├── main.dart                       # App entry point with Provider setup
├── firebase_options.dart           # Firebase configuration
│
├── models/                         # Data models
│   ├── user.dart                   # User model with profile data
│   └── message.dart                # Message model with sync status
│
├── providers/                      # State management
│   ├── auth_provider.dart          # Authentication state
│   └── chat_provider.dart          # Chat state
│
├── services/                       # Business logic
│   ├── auth_service.dart           # Firebase Authentication
│   ├── biometric_service.dart      # Biometric authentication
│   ├── firebase_service.dart       # Firestore operations
│   ├── chat_service.dart           # Chat management
│   └── notification_service.dart   # FCM handling
│
├── database/                       # Local storage
│   └── database_helper.dart        # SQLite operations
│
└── screens/                        # UI screens
    ├── login_screen.dart           # Login UI
    ├── register_screen.dart        # Registration UI
    ├── users_screen.dart           # User list
    └── chat_screen.dart            # Chat interface
```

## 🎮 How to Use

### First Time Setup
1. **Launch the app** - You'll see the login screen
2. **Create an account** - Click "Sign Up" and register
3. **Enable biometric** (optional) - Check "Remember me" when logging in

### Using the App
1. **Login** - Use email/password or biometric
2. **Browse users** - See all registered users on the home screen
3. **Start chatting** - Tap on any user to open a conversation
4. **Send messages** - Type and send messages in real-time
5. **Receive notifications** - Get notified of new messages

### Testing Multiple Users
1. Register two accounts on different devices/emulators
2. Start a chat from one device
3. Messages appear instantly on both devices
4. Test offline mode by disabling network
5. Messages sync automatically when back online

## 🔧 Configuration Options

### Customize Colors
Edit `lib/screens/chat_screen.dart`:
```dart
const currentColor = Color(0xFF6C63FF); // Change primary color
```

### Customize App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Your App Name"
```

### Notification Channel
Edit `lib/services/notification_service.dart` to customize notification behavior.

## 📦 Dependencies

```yaml
dependencies:
  # Core
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Firebase
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.0
  firebase_auth: ^5.3.3
  firebase_messaging: ^15.1.4
  
  # State Management
  provider: ^6.1.2
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Biometric
  local_auth: ^2.3.0
  flutter_secure_storage: ^9.2.2
  
  # Utilities
  intl: ^0.19.0
  shared_preferences: ^2.3.3
```

## 🐛 Troubleshooting

### Firebase Connection Issues
```bash
# Reconfigure Firebase
flutterfire configure

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Biometric Not Working
- Test on a physical device (emulator support varies)
- Ensure biometric is set up in device settings
- Check permissions in AndroidManifest.xml

### Messages Not Syncing
- Verify internet connection
- Check Firestore security rules
- Review Firebase Console logs
- Check app logs: `flutter logs`

### Notifications Not Appearing
- Grant notification permission when prompted
- Check FCM is enabled in Firebase Console
- Verify FCM token generation in logs
- Test on physical device (emulator limitations)

### Build Errors
```bash
# Android
flutter clean
cd android && ./gradlew clean && cd ..
flutter run

# iOS
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter run
```

## 🧪 Testing

### Manual Testing Checklist
- [ ] Register new user
- [ ] Login with email/password
- [ ] Enable biometric login
- [ ] Logout and login with biometric
- [ ] Send messages between users
- [ ] Test offline mode
- [ ] Verify message sync
- [ ] Test push notifications
- [ ] Clear conversation
- [ ] Test error handling

### Automated Tests
```bash
flutter test
```

## 📱 Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then use Xcode to archive and upload
```

## 📚 Documentation

- [Implementation Guide](IMPLEMENTATION_GUIDE.md) - Detailed technical docs
- [Firebase Setup](FIREBASE_SETUP.md) - Firebase configuration
- [Quick Start](QUICK_START.md) - Quick reference guide

## 🎯 Future Enhancements

- [ ] Group chat support
- [ ] Image/file sharing
- [ ] Voice messages
- [ ] Video calls
- [ ] Message reactions (👍❤️😂)
- [ ] User status (online/offline/typing)
- [ ] Message search
- [ ] Custom themes
- [ ] End-to-end encryption
- [ ] Message editing/deletion
- [ ] User blocking

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for comprehensive backend services
- Provider package for elegant state management
- Local Auth for biometric support
- The Flutter community for inspiration

## 📞 Support

Need help? Here's how to get support:

1. **Documentation** - Check IMPLEMENTATION_GUIDE.md
2. **Firebase Console** - Review logs and configuration
3. **Flutter Doctor** - Run `flutter doctor` for diagnostics
4. **GitHub Issues** - Open an issue with details
5. **Stack Overflow** - Tag with `flutter` and `firebase`

## 🌟 Show Your Support

If you found this project helpful, please give it a ⭐️!

---

**Built with ❤️ using Flutter & Firebase**

Happy Coding! 🎉
