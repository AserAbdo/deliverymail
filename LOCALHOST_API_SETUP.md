# 🌐 Localhost API Configuration Guide

## Current Issue

You're running Laravel on localhost, but the Flutter app needs the correct URL to connect.

## ✅ Step-by-Step Fix

### Step 1: Find Out Where You're Running the App

Are you testing on:
- **Android Emulator**? (running on your computer)
- **iOS Simulator**? (Mac only)
- **Physical Device**? (real phone connected via USB or WiFi)
- **Chrome/Web**?

### Step 2: Get Your Computer's IP Address (if using Physical Device)

**Windows**:
```bash
ipconfig
```
Look for "IPv4 Address" (e.g., `192.168.1.100`)

**Mac/Linux**:
```bash
ifconfig
```
Look for "inet" address (e.g., `192.168.1.100`)

### Step 3: Update `api_config.dart`

Open: `lib/core/api/api_config.dart`

**Option A: Android Emulator** (currently set ✅)
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**Option B: iOS Simulator or Chrome**
```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

**Option C: Physical Device**
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
// Example:
// static const String baseUrl = 'http://192.168.1.100:8000/api';
```

### Step 4: Verify Laravel is Running

**Check Laravel is accessible**:

1. Open browser
2. Go to: `http://localhost:8000/api/products` (or `http://127.0.0.1:8000/api/products`)
3. You should see JSON data

If you get an error:
```bash
# Make sure Laravel is running:
cd path/to/your/laravel/project
php artisan serve

# You should see:
# Starting Laravel development server: http://127.0.0.1:8000
```

### Step 5: Test API from Emulator/Device Perspective

**For Android Emulator**, test:
- `http://10.0.2.2:8000/api/products`

**For Physical Device**, test from phone browser:
- `http://YOUR_IP:8000/api/products`

If you can't access it, check:
1. ✅ Laravel is running
2. ✅ Your computer firewall allows connections on port 8000
3. ✅ Phone and computer are on the same WiFi network (for physical device)

### Step 6: Restart Flutter App

After changing the URL:
```bash
# Full restart (required!)
flutter clean
flutter pub get
flutter run
```

## 🔍 Debugging

### Check Console Output

You'll see logs like:
```
🔍 Fetching products with URL: http://10.0.2.2:8000/api/products
🌐 API GET: http://10.0.2.2:8000/api/products?page=1&per_page=100
```

Make sure the URL matches what you set!

### Common Issues

**Issue 1: Connection Refused**
```
❌ API Error: Connection refused
```

**Solutions**:
- Make sure Laravel is running (`php artisan serve`)
- Check you're using the right URL for your device
- Check firewall settings

**Issue 2: Timeout**
```
❌ API Error: Timeout
```

**Solutions**:
- Check Laravel is accessible from browser first
- For physical device: make sure both are on same WiFi
- Try pinging your computer from phone

**Issue 3: 404 Not Found**
```
API Error: 404
```

**Solutions**:
- Verify Laravel routes with: `php artisan route:list`
- Make sure `/api/products` endpoint exists
- Check Laravel is actually serving on port 8000

## 🎯 Quick Checklist

- [ ] Laravel is running (`php artisan serve`)
- [ ] Can access `http://localhost:8000/api/products` in browser
- [ ] Updated `baseUrl` in `api_config.dart` for your device type
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Restarted Flutter app (not just hot reload)
- [ ] Checked console logs show correct URL

## 📝 Example Setup

**Testing on Android Emulator**:

1. Laravel running:
   ```bash
   php artisan serve
   # Server running on http://127.0.0.1:8000
   ```

2. Flutter config:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000/api';  // ✅
   ```

3. Test in browser: `http://localhost:8000/api/products` ✅
4. Flutter app will call: `http://10.0.2.2:8000/api/products` ✅

---

**Which device are you testing on? Update the `baseUrl` accordingly!** 🚀
