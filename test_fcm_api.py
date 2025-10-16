#!/usr/bin/env python3
"""
FCM API Test Script
This script helps you test your FCM notification API endpoint.
"""

import requests
import json
import sys

# API Configuration
API_URL = "https://staging.hourandmore.sa/api/send-fcm-notification"

def test_fcm_notification(token, title="Test Notification", message="This is a test notification from Python script!"):
    """
    Test the FCM notification API endpoint
    
    Args:
        token (str): FCM token from your Flutter app
        title (str): Notification title
        message (str): Notification message
    """
    
    payload = {
        "title": title,
        "message": message,
        "token": token
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    print(f"🚀 Testing FCM API...")
    print(f"   URL: {API_URL}")
    print(f"   Title: {title}")
    print(f"   Message: {message}")
    print(f"   Token: {token[:20]}...")
    print()
    
    try:
        response = requests.post(API_URL, json=payload, headers=headers, timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📊 Response Headers: {dict(response.headers)}")
        print(f"📊 Response Body: {response.text}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Notification sent successfully!")
            try:
                response_data = response.json()
                print(f"   Response Data: {json.dumps(response_data, indent=2)}")
            except:
                print("   (Response is not JSON)")
        else:
            print(f"❌ FAILED: HTTP {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ ERROR: {e}")
    except Exception as e:
        print(f"❌ UNEXPECTED ERROR: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python test_fcm_api.py <FCM_TOKEN> [title] [message]")
        print()
        print("Example:")
        print("  python test_fcm_api.py 'your-fcm-token-here'")
        print("  python test_fcm_api.py 'your-fcm-token-here' 'Custom Title' 'Custom Message'")
        sys.exit(1)
    
    token = sys.argv[1]
    title = sys.argv[2] if len(sys.argv) > 2 else "Test Notification"
    message = sys.argv[3] if len(sys.argv) > 3 else "This is a test notification from Python script!"
    
    test_fcm_notification(token, title, message)

if __name__ == "__main__":
    main()

