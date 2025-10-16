# FCM Testing Guide 🚀

This guide will help you test your Firebase Cloud Messaging (FCM) setup with your Flutter app and backend API.

## What You Have ✅

- **Firebase Project**: `hourandmorechatapp`
- **Backend API**: `https://staging.hourandmore.sa/api/send-fcm-notification`
- **Flutter App**: Configured with FCM
- **Admin SDK**: Your backend has access to your Firebase project

## Testing Steps 📱

### 1. Run Your Flutter App
```bash
flutter run
```

### 2. Access FCM Test Screen
- Open your app
- Tap the **notification icon** (🔔) floating action button
- This opens the FCM Test Screen

### 3. Get Your FCM Token
- The test screen will display your FCM token
- Copy this token (it's selectable text)

### 4. Test Notifications

#### Option A: Use the In-App Test
- Enter a custom title and message (optional)
- Tap "Send Test Notification"
- Watch the logs for results

#### Option B: Use the Python Script
```bash
python test_fcm_api.py "YOUR_FCM_TOKEN_HERE"
```

#### Option C: Use curl
```bash
curl -X POST https://staging.hourandmore.sa/api/send-fcm-notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "message": "Hello from curl!",
    "token": "YOUR_FCM_TOKEN_HERE"
  }'
```

## Test Scenarios 🧪

### 1. Foreground Notifications
- Keep app open
- Send notification
- Check logs in test screen

### 2. Background Notifications
- Minimize app (don't close)
- Send notification
- Check if notification appears in system tray

### 3. Terminated App Notifications
- Close app completely
- Send notification
- Check if notification appears and opens app when tapped

## Troubleshooting 🔧

### No FCM Token?
- Check notification permissions
- Restart app
- Check Firebase configuration

### API Errors?
- Verify token is correct
- Check network connection
- Verify API endpoint is accessible

### Notifications Not Received?
- Check device notification settings
- Verify FCM token is valid
- Check Firebase console for delivery status

## Expected Results ✅

- **API Response**: 200 status with success message
- **Foreground**: Logs show notification received
- **Background**: System notification appears
- **Terminated**: App opens when notification tapped

## Next Steps 🎯

Once testing is successful:
1. Integrate FCM into your chat functionality
2. Send notifications for new messages
3. Add notification sound and vibration
4. Implement notification actions

Happy Testing! 🎉

