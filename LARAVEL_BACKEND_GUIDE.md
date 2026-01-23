# 🔥 Firebase ID Token Configuration
# إعداد رمز Firebase ID Token

## 📸 Your Backend Response Format

Based on your image, your Laravel backend should return the Firebase ID token like this:

```json
{
  "id_token": "YOUR_FIREBASE_ID_TOKEN_HERE"
}
```

## ⚠️ Important Note / ملاحظة مهمة

The image you provided shows the **expected response format** from your Laravel backend.

However, for the Google Sign-In flow to work properly, your backend needs to:

1. **Receive** the ID token from Flutter
2. **Verify** it with Google
3. **Return** your app's authentication token

---

## 🔄 Correct Flow / التدفق الصحيح

### Step 1: Flutter Sends to Laravel

**Endpoint:** `POST {{base_url}}/auth/google`

**Request Body:**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE4MmU...",
  "email": "user@gmail.com",
  "name": "User Name",
  "photo_url": "https://lh3.googleusercontent.com/..."
}
```

### Step 2: Laravel Verifies & Responds

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "your_app_bearer_token_here",
    "user": {
      "id": 1,
      "name": "User Name",
      "email": "user@gmail.com",
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  }
}
```

---

## 💻 Laravel Backend Implementation

### Controller: `AuthController.php`

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Google\Client as GoogleClient;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Handle Google Sign-In
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function googleSignIn(Request $request)
    {
        try {
            // Validate request
            $request->validate([
                'id_token' => 'required|string',
                'email' => 'required|email',
                'name' => 'required|string',
            ]);

            $idToken = $request->input('id_token');
            
            // Initialize Google Client
            $client = new GoogleClient([
                'client_id' => env('GOOGLE_CLIENT_ID')
            ]);
            
            // Verify the ID token
            $payload = $client->verifyIdToken($idToken);
            
            if (!$payload) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid ID token'
                ], 401);
            }
            
            // Extract user information
            $email = $payload['email'];
            $name = $payload['name'] ?? $request->input('name');
            $googleId = $payload['sub'];
            $emailVerified = $payload['email_verified'] ?? false;
            
            // Find or create user
            $user = User::where('email', $email)->first();
            
            if (!$user) {
                // Create new user
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'google_id' => $googleId,
                    'email_verified_at' => $emailVerified ? now() : null,
                    'password' => Hash::make(uniqid()), // Random password
                ]);
            } else {
                // Update existing user with Google ID if not set
                if (!$user->google_id) {
                    $user->update([
                        'google_id' => $googleId,
                        'email_verified_at' => $emailVerified ? now() : $user->email_verified_at,
                    ]);
                }
            }
            
            // Create authentication token (Laravel Sanctum)
            $token = $user->createToken('auth_token')->plainTextToken;
            
            // Return success response
            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'token' => $token,
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'created_at' => $user->created_at,
                    ]
                ]
            ], 200);
            
        } catch (\Google\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Google verification failed: ' . $e->getMessage()
            ], 500);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication failed: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 🗄️ Database Migration

Add `google_id` column to users table:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('google_id')->nullable()->unique()->after('email');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('google_id');
        });
    }
};
```

Run migration:
```bash
php artisan make:migration add_google_id_to_users_table
php artisan migrate
```

---

## 🛣️ Routes

Add to `routes/api.php`:

```php
use App\Http\Controllers\AuthController;

// Google Sign-In
Route::post('/auth/google', [AuthController::class, 'googleSignIn']);
```

---

## 📦 Required Packages

### Install Google API Client:

```bash
composer require google/apiclient
```

### Install Laravel Sanctum (if not already):

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

---

## 🔐 Environment Variables

Add to `.env`:

```env
# Google Sign-In Configuration
GOOGLE_CLIENT_ID=your_web_client_id_from_firebase.apps.googleusercontent.com
```

**Where to find Web Client ID:**
1. Firebase Console → Project Settings
2. Scroll to "Your apps"
3. Click Web app (or add one)
4. Copy the **Web client ID**

---

## 🧪 Testing the Endpoint

### Using Postman or cURL:

```bash
curl -X POST https://deliverymall.developerxsoftware.com/api/auth/google \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE4MmU...",
    "email": "test@gmail.com",
    "name": "Test User"
  }'
```

### Expected Response:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "1|abcdefghijklmnopqrstuvwxyz",
    "user": {
      "id": 1,
      "name": "Test User",
      "email": "test@gmail.com",
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  }
}
```

---

## ✅ Verification Checklist

Before testing with Flutter app:

- [ ] Google API Client installed (`composer require google/apiclient`)
- [ ] Laravel Sanctum installed and configured
- [ ] Migration run (added `google_id` column)
- [ ] Route added to `routes/api.php`
- [ ] `GOOGLE_CLIENT_ID` added to `.env`
- [ ] Controller created with verification logic
- [ ] Endpoint tested with Postman/cURL

---

## 🔍 Debugging

### Check if ID token is valid:

```php
// In your controller
\Log::info('ID Token received:', ['token' => $idToken]);
\Log::info('Payload:', ['payload' => $payload]);
```

### Common Issues:

1. **"Invalid ID token"**
   - Check `GOOGLE_CLIENT_ID` in `.env`
   - Ensure it's the **Web client ID** from Firebase

2. **"Google verification failed"**
   - Install `google/apiclient` package
   - Check internet connection on server

3. **"Token mismatch"**
   - Verify Web client ID matches Firebase project

---

## 📱 Flutter Side (Already Implemented)

The Flutter app will automatically:
1. Get ID token from Firebase
2. Send it to your Laravel endpoint
3. Receive and save the bearer token
4. Use it for authenticated requests

**No changes needed on Flutter side!** ✅

---

## 🎯 Summary

### What the Image Shows:
- Expected response format with `id_token`

### What You Need to Implement:
1. ✅ Install `google/apiclient` in Laravel
2. ✅ Add `GOOGLE_CLIENT_ID` to `.env`
3. ✅ Create `/auth/google` endpoint
4. ✅ Verify ID token with Google
5. ✅ Return your app's bearer token

### Response Format:
```json
{
  "success": true,
  "data": {
    "token": "YOUR_APP_TOKEN",
    "user": { ... }
  }
}
```

---

**Ready to implement! 🚀**
**جاهز للتنفيذ! 🚀**
