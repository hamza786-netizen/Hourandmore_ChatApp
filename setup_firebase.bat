@echo off
echo ========================================
echo Firebase Setup for Chat App
echo ========================================
echo.

echo Step 1: Installing FlutterFire CLI...
call dart pub global activate flutterfire_cli

echo.
echo Step 2: Configuring Firebase...
echo Please select your Firebase project when prompted
call flutterfire configure

echo.
echo Step 3: Getting dependencies...
call flutter pub get

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Go to Firebase Console: https://console.firebase.google.com/
echo 2. Enable Firestore Database (Start in test mode)
echo 3. Run: flutter run -d windows
echo.
echo For detailed instructions, see FIREBASE_SETUP.md
echo.
pause




