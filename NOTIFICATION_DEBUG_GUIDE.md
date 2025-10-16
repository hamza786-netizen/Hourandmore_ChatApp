# 🔧 Notification Debug Guide

## Quick Fix Steps

### 1. **Check Permissions First**
- Open the FCM Test Screen
- Tap "Check Permissions" (blue button)
- Look for "✅ Notification permissions granted" in logs
- If denied, go to device Settings > Apps > Your App > Notifications

### 2. **Test Local Notifications**
- Tap "Test Local" (orange button)
- Should see a notification appear immediately
- If this doesn't work, there's a device/permission issue

### 3. **Test FCM Notifications**
- Only test FCM after local notifications work
- Tap "Send FCM Notification" (purple button)
- Check logs for detailed debugging info

## Common Issues & Solutions

### ❌ **No Notifications Appear**

**Possible Causes:**
1. **Notification permissions denied**
   - Solution: Enable in device settings
   - Check: Use "Check Permissions" button

2. **Device notification settings**
   - Solution: Check device notification settings
   - Android: Settings > Apps > Your App > Notifications
   - iOS: Settings > Notifications > Your App

3. **Do Not Disturb mode**
   - Solution: Turn off Do Not Disturb
   - Check: Look for DND icon in status bar

4. **App notification channels disabled**
   - Solution: Check notification channels in device settings
   - Android: Settings > Apps > Your App > Notifications > Categories

### 🔍 **Debugging Steps**

1. **Check Logs:**
   ```
   ✅ Local notifications initialized successfully
   ✅ Notification permissions granted
   ✅ Test local notification sent
   ✅ Local notification displayed successfully
   ```

2. **Test Sequence:**
   - Check Permissions → Should show "granted"
   - Test Local → Should show notification immediately
   - Test FCM → Should show notification + API success

3. **Check Device Settings:**
   - Notification permissions: ON
   - Notification channels: Enabled
   - Do Not Disturb: OFF
   - App-specific settings: All enabled

### 📱 **Platform-Specific Issues**

**Android:**
- Check notification channels are enabled
- Verify app has notification permission
- Check if battery optimization is affecting notifications

**iOS:**
- Check notification permissions in Settings
- Verify app is not in background app refresh restrictions
- Check if Focus modes are blocking notifications

## Expected Behavior

### ✅ **Working Correctly:**
- Local notifications appear immediately
- FCM notifications appear in all app states
- Logs show success messages
- API returns 200 status

### ❌ **Not Working:**
- No notifications appear
- Logs show permission errors
- API returns error status
- Local notification test fails

## Next Steps

1. **If local notifications work but FCM doesn't:**
   - Check FCM token is valid
   - Verify API endpoint is working
   - Check Firebase console for delivery status

2. **If nothing works:**
   - Check device notification settings
   - Try on different device
   - Check app permissions thoroughly

3. **If everything works:**
   - Integrate into chat functionality
   - Add notification sounds and vibrations
   - Test with real users

## Debug Commands

```bash
# Check app compilation
flutter analyze

# Run app in debug mode
flutter run --debug

# Check device logs (Android)
adb logcat | grep -i notification

# Check device logs (iOS)
# Use Xcode Console or device logs
```

## Still Having Issues?

1. **Check the logs** in the FCM Test Screen
2. **Try on a different device** to isolate the issue
3. **Check Firebase Console** for delivery reports
4. **Verify API endpoint** is working with curl/Postman
5. **Test with a simple notification** first

Remember: Local notifications must work before FCM notifications will work!

