# 🚀 Flutter Chat App with Firebase Authentication

## ✨ Features

--> Complete Authentication System
- **Email/Password Authentication** - Secure Firebase authentication
- **User Registration** - Create new accounts with validation
- **Biometric Login** - Quick access with fingerprint/Face ID
- **Password Reset** - Email-based password recovery
- **Session Persistence** - Stay logged in across app restarts
- **Secure Storage** - Encrypted credential storage

--> Real-time Chat
- **Instant Messaging** - Real-time message delivery with Firebase Firestore
- **Private Conversations** - One-on-one chat between users
- **Message Persistence** - Local SQLite database for offline access
- **Auto Sync** - Messages sync automatically when online
- **Read Receipts** - See when messages are delivered and read
- **Offline Support** - Send and receive messages without internet
- **Beautiful UI** - Modern Material Design 3 with gradient themes

--> Push Notifications
- **Firebase Cloud Messaging** - Real-time push notifications
- **Background Notifications** - Receive messages when app is closed
- **Foreground Notifications** - In-app notification handling
- **Notification Actions** - Tap to open conversation
- **Custom Sounds** - Configurable notification tones

--> User Management
- **User List Screen** - Browse all registered users
- **Profile Management** - User profiles with avatars
- **Online Status** - Real-time connection indicators
- **Search Users** - Find and start conversations

--> 🏗️ Clean Architecture
- **Provider State Management** - Reactive and efficient
- **Service Layer Pattern** - Modular business logic
- **Repository Pattern** - Data abstraction
- **Comprehensive Error Handling** - User-friendly error messages
- **Type-safe Code** - Full Dart type safety

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
* Passwords never stored in plain text  
* Biometric credentials in secure storage   
* Input validation on all forms  
* HTTPS-only connections  
* Token-based authentication  

## 📋 Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **Firebase Account** - Free tier is sufficient
- **Android Studio / Xcode** - For building native apps
- **Physical Device** - For biometric testing (emulator support varies)

