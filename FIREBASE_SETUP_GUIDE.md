# Firebase Configuration Guide for Google Sign-In
# دليل إعداد Firebase لتسجيل الدخول بواسطة Google

## 📋 Overview / نظرة عامة

This guide will help you configure Firebase for Google Sign-In in your Flutter app.
سيساعدك هذا الدليل في إعداد Firebase لتسجيل الدخول بواسطة Google في تطبيق Flutter.

---

## 🔥 Firebase Console Setup / إعداد Firebase Console

### Step 1: Create Firebase Project / الخطوة 1: إنشاء مشروع Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" / انقر على "إضافة مشروع"
3. Enter project name: `deliverymall` or your preferred name
4. Enable Google Analytics (optional) / تفعيل Google Analytics (اختياري)
5. Click "Create Project" / انقر على "إنشاء المشروع"

### Step 2: Add Android App / الخطوة 2: إضافة تطبيق Android

1. In Firebase Console, click the Android icon
2. **Android Package Name**: `com.deliverymall.khodargy` (or your package name from `android/app/build.gradle`)
3. **App Nickname**: DeliveryMall (optional)
4. **Debug Signing Certificate SHA-1**: 
   - Run this command in your project directory:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Copy the SHA-1 from the debug keystore
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

### Step 3: Add iOS App / الخطوة 3: إضافة تطبيق iOS

1. In Firebase Console, click the iOS icon
2. **iOS Bundle ID**: `com.deliverymall.khodargy` (or your bundle ID from `ios/Runner.xcodeproj`)
3. **App Nickname**: DeliveryMall (optional)
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/GoogleService-Info.plist`
6. Open Xcode and add the file to the Runner project

### Step 4: Enable Google Sign-In / الخطوة 4: تفعيل تسجيل الدخول بواسطة Google

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Google**
3. Enable the toggle
4. Set **Project support email** (your email)
5. Click **Save**

---

## 📱 Android Configuration / إعداد Android

### 1. Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 2. Update `android/app/build.gradle`:

```gradle
// At the bottom of the file, add:
apply plugin: 'com.google.gms.google-services'
```

### 3. Update `android/app/src/main/AndroidManifest.xml`:

No changes needed for Google Sign-In, but ensure you have internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🍎 iOS Configuration / إعداد iOS

### 1. Update `ios/Runner/Info.plist`:

Add the following inside `<dict>`:

```xml
<!-- Google Sign-In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**To find your REVERSED_CLIENT_ID:**
1. Open `ios/Runner/GoogleService-Info.plist`
2. Look for the key `REVERSED_CLIENT_ID`
3. Copy its value
4. Replace `com.googleusercontent.apps.YOUR-CLIENT-ID` with that value

### 2. Update `ios/Podfile`:

Ensure you have at least iOS 12.0:

```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios
pod install
```

---

## 🔧 Laravel Backend Configuration / إعداد Laravel Backend

### API Endpoint: `/auth/google`

Your Laravel backend should handle the Google Sign-In like this:

```php
// routes/api.php
Route::post('/auth/google', [AuthController::class, 'googleSignIn']);
```

### Controller Implementation:

```php
// app/Http/Controllers/AuthController.php

use Google\Client as GoogleClient;

public function googleSignIn(Request $request)
{
    try {
        $idToken = $request->input('id_token');
        
        // Verify the ID token with Google
        $client = new GoogleClient(['client_id' => env('GOOGLE_CLIENT_ID')]);
        $payload = $client->verifyIdToken($idToken);
        
        if (!$payload) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid ID token'
            ], 401);
        }
        
        // Get user info from payload
        $email = $payload['email'];
        $name = $payload['name'];
        $googleId = $payload['sub'];
        
        // Find or create user
        $user = User::firstOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'google_id' => $googleId,
                'email_verified_at' => now(),
            ]
        );
        
        // Create token
        $token = $user->createToken('auth_token')->plainTextToken;
        
        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => $user
            ]
        ]);
        
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Authentication failed: ' . $e->getMessage()
        ], 500);
    }
}
```

### Install Google API Client in Laravel:

```bash
composer require google/apiclient
```

### Add to `.env`:

```env
GOOGLE_CLIENT_ID=YOUR_FIREBASE_WEB_CLIENT_ID
```

**To find your Web Client ID:**
1. Go to Firebase Console → Project Settings
2. Scroll down to "Your apps"
3. Click on the Web app (or add one if you don't have it)
4. Copy the **Web client ID**

### Update User Migration (if needed):

```php
Schema::table('users', function (Blueprint $table) {
    $table->string('google_id')->nullable()->unique();
});
```

---

## 🎯 Firebase Project Settings / إعدادات مشروع Firebase

### Get Your Firebase Configuration:

1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps"
3. You'll see your apps listed

### Important Values You Need:

From **Web App** configuration:
```javascript
{
  "apiKey": "YOUR_API_KEY",
  "authDomain": "YOUR_PROJECT_ID.firebaseapp.com",
  "projectId": "YOUR_PROJECT_ID",
  "storageBucket": "YOUR_PROJECT_ID.appspot.com",
  "messagingSenderId": "YOUR_SENDER_ID",
  "appId": "YOUR_APP_ID"
}
```

**For Laravel Backend:**
- Use the **Web client ID** for `GOOGLE_CLIENT_ID` in `.env`

---

## 📝 Testing / الاختبار

### Test Google Sign-In:

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Click on "تسجيل الدخول" (Login)
3. Click on "متابعة بواسطة Google"
4. Select a Google account
5. The app should authenticate and navigate to the main screen

### Troubleshooting / حل المشاكل:

**Problem:** "Sign in failed" or "Invalid ID token"
- **Solution:** Make sure SHA-1 is correctly added in Firebase Console
- Rebuild the app after adding `google-services.json`

**Problem:** "PlatformException"
- **Solution:** Check that `google-services.json` and `GoogleService-Info.plist` are in the correct locations

**Problem:** Backend returns "Invalid ID token"
- **Solution:** Verify that `GOOGLE_CLIENT_ID` in Laravel `.env` matches the Web client ID from Firebase

---

## 📦 Required Files Checklist / قائمة الملفات المطلوبة

- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ `android/build.gradle` (updated with google-services plugin)
- ✅ `android/app/build.gradle` (applied google-services plugin)
- ✅ `ios/Runner/Info.plist` (added REVERSED_CLIENT_ID)

---

## 🔐 Security Notes / ملاحظات الأمان

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repositories
2. Add them to `.gitignore`:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```
3. Use environment variables for sensitive data in Laravel
4. Always verify ID tokens on the backend

---

## 📞 Support / الدعم

If you encounter any issues:
1. Check Firebase Console logs
2. Check Flutter console for errors
3. Verify all configuration files are in place
4. Ensure backend API is accessible

---

## ✅ Summary / الملخص

**What you need to do:**

1. ✅ Create Firebase project
2. ✅ Add Android app (download `google-services.json`)
3. ✅ Add iOS app (download `GoogleService-Info.plist`)
4. ✅ Enable Google Sign-In in Firebase Authentication
5. ✅ Update Android configuration files
6. ✅ Update iOS configuration files
7. ✅ Install dependencies: `flutter pub get`
8. ✅ Configure Laravel backend with Google API Client
9. ✅ Add Web client ID to Laravel `.env`
10. ✅ Test the app!

**Backend Response Format:**

Your Laravel backend should return:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "YOUR_BEARER_TOKEN",
    "user": {
      "id": 1,
      "name": "User Name",
      "email": "user@example.com"
    }
  }
}
```

---

Good luck! 🚀 حظاً موفقاً
