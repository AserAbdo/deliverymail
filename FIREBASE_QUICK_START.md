# 🔥 Firebase Quick Setup - What You Need to Do
# الإعداد السريع لـ Firebase - ما تحتاج إلى فعله

## ⚡ Quick Start (5 Steps)

### 1️⃣ Create Firebase Project
1. Go to: https://console.firebase.google.com/
2. Click "Add Project"
3. Name: `deliverymall` (or any name)
4. Click "Create Project"

---

### 2️⃣ Add Android App

1. Click Android icon in Firebase Console
2. **Package Name**: `com.deliverymall.khodargy`
   - Find it in: `android/app/build.gradle` → look for `applicationId`
3. Get SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 from "Task :app:signingReport"
4. Download `google-services.json`
5. **Place it here**: `android/app/google-services.json`

---

### 3️⃣ Add iOS App

1. Click iOS icon in Firebase Console
2. **Bundle ID**: `com.deliverymall.khodargy`
   - Find it in Xcode or `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. **Place it here**: `ios/Runner/GoogleService-Info.plist`
5. Open `GoogleService-Info.plist` and copy the `REVERSED_CLIENT_ID` value

---

### 4️⃣ Enable Google Sign-In

1. In Firebase Console → **Authentication**
2. Click **Sign-in method** tab
3. Click **Google**
4. Toggle **Enable**
5. Add your support email
6. Click **Save**

---

### 5️⃣ Get Web Client ID for Laravel

1. Firebase Console → **Project Settings** (gear icon)
2. Scroll to "Your apps"
3. Click on **Web app** (or add one if missing)
4. Copy the **Web client ID**
5. Add to Laravel `.env`:
   ```env
   GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID_HERE
   ```

---

## 📋 Files You Need to Download from Firebase

| File | Location | Platform |
|------|----------|----------|
| `google-services.json` | `android/app/` | Android |
| `GoogleService-Info.plist` | `ios/Runner/` | iOS |

---

## 🔧 Laravel Backend Setup

### 1. Install Google API Client

```bash
composer require google/apiclient
```

### 2. Add to `.env`

```env
GOOGLE_CLIENT_ID=your_web_client_id_from_firebase
```

### 3. API Endpoint Response Format

Your `/auth/google` endpoint should return:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "user_bearer_token_here",
    "user": {
      "id": 1,
      "name": "User Name",
      "email": "user@example.com"
    }
  }
}
```

### 4. Expected Request from Flutter

```json
{
  "id_token": "firebase_id_token_here",
  "email": "user@example.com",
  "name": "User Name",
  "photo_url": "https://..."
}
```

---

## ✅ Verification Checklist

Before testing, make sure:

- [ ] `google-services.json` is in `android/app/`
- [ ] `GoogleService-Info.plist` is in `ios/Runner/`
- [ ] Google Sign-In is enabled in Firebase Console
- [ ] Web Client ID is added to Laravel `.env`
- [ ] Laravel has `google/apiclient` installed
- [ ] `/auth/google` endpoint is working

---

## 🧪 Test It!

1. Run the app:
   ```bash
   flutter run
   ```

2. Click "تسجيل الدخول" (Login button)

3. Click "متابعة بواسطة Google"

4. Select a Google account

5. Should see success message and navigate to home screen

---

## 🆘 Common Issues

### "Sign in failed"
- **Fix**: Check SHA-1 is added in Firebase Console
- Rebuild app after adding `google-services.json`

### "Invalid ID token" (Backend)
- **Fix**: Verify `GOOGLE_CLIENT_ID` in Laravel `.env` matches Web client ID from Firebase

### "PlatformException"
- **Fix**: Ensure config files are in correct locations
- Clean and rebuild: `flutter clean && flutter pub get`

---

## 📞 Need Help?

See the full guide: `FIREBASE_SETUP_GUIDE.md`

---

**That's it! You're ready to go! 🚀**
**هذا كل شيء! أنت جاهز! 🚀**
