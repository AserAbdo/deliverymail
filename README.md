# Khodargy (خضرجي) - Flutter Mobile App

A beautiful Arabic-language mobile app for ordering fresh vegetables and fruits, built with Flutter and connected to a Laravel backend API.

## 📱 Features

- ✅ Browse products (vegetables & fruits)
- ✅ Search products
- ✅ Filter by category
- ✅ Add to cart
- ✅ Beautiful Arabic UI with RTL support
- ✅ Real-time data from API
- ✅ Pull-to-refresh
- ✅ Loading and error states
- 🔄 User authentication (coming soon)
- 🔄 Order placement (coming soon)
- 🔄 Order tracking (coming soon)

## 🚀 Quick Start

### Prerequisites

Make sure you have installed:
- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Android Studio / Xcode
- PHP 8.1+ (for backend, with SQLite extension)
- Composer (for backend)

**Note:** No MySQL needed! Backend uses SQLite database. 🎉

### 1. Setup Flutter App

```bash
cd C:\Users\Admin\Desktop\khodargy
flutter pub get
```

### 2. Setup Laravel Backend

**See detailed guide:** [LARAVEL_SETUP_GUIDE.md](./LARAVEL_SETUP_GUIDE.md)

Quick steps:
```bash
# Clone backend repository
git clone <BACKEND_GITHUB_URL> delivery-mall-backend
cd delivery-mall-backend

# Install and setup
composer install
copy .env.example .env
php artisan key:generate

# Create SQLite database
type nul > database\database.sqlite

# Run migrations and seeders
php artisan migrate
php artisan db:seed

# Start server
php artisan serve
```

### 3. Configure API URL

Edit `lib/core/api/api_config.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**For Physical Device:**
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api';
```

Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

### 4. Run the App

```bash
flutter run
```

## 📚 Documentation

- **[LARAVEL_SETUP_GUIDE.md](./LARAVEL_SETUP_GUIDE.md)** - Complete guide to setup Laravel backend
- **[API_INTEGRATION_SUMMARY.md](./API_INTEGRATION_SUMMARY.md)** - Summary of API integration changes
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Quick command reference
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture overview

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   └── api/                     # API configuration
├── models/                      # Data models
├── services/                    # API services
├── screens/                     # UI screens
├── widgets/                     # Reusable widgets
└── data/                        # Legacy data (not used)
```

## 🔌 API Endpoints

The app connects to these Laravel API endpoints:

### Products
- `GET /api/products` - List products
- `GET /api/products/{id}` - Product details

### Categories
- `GET /api/categories` - List categories
- `GET /api/categories/{id}` - Category details

### Orders (Authentication required)
- `GET /api/orders` - My orders
- `POST /api/orders` - Create order
- `GET /api/orders/{id}` - Order details

### Authentication
- `POST /api/register` - Register
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/user` - Current user

## 🎨 Design Features

- **Modern UI** with Material Design 3
- **Arabic Typography** using Cairo font
- **RTL Support** for Arabic language
- **Smooth Animations** with staggered grid
- **Beautiful Color Scheme**:
  - Primary: Fresh Green (#2E7D32)
  - Secondary: Orange (#FF6F00)
  - Tertiary: Pink (#E91E63)

## 🛠️ Technologies Used

### Flutter App
- Flutter 3.10+
- Dart
- HTTP package for API calls
- Google Fonts (Cairo)
- Cached Network Image
- Flutter Staggered Animations
- Badges

### Backend (Laravel)
- PHP 8.1+
- Laravel Framework
- MySQL Database
- RESTful API

## 🔧 Development

### Run in Development Mode
```bash
# Terminal 1: Start Laravel
cd delivery-mall-backend
php artisan serve

# Terminal 2: Run Flutter
cd khodargy
flutter run
```

### Hot Reload
While the app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Build APK
```bash
flutter build apk
```

## 🐛 Troubleshooting

### App shows "Failed to load products"
1. Check if Laravel server is running
2. Verify API URL in `lib/core/api/api_config.dart`
3. Test API in browser: `http://127.0.0.1:8000/api/products`

### Connection refused on physical device
1. Use your computer's IP address (not 127.0.0.1)
2. Start Laravel with: `php artisan serve --host=0.0.0.0`
3. Make sure phone and computer are on same WiFi

### Arabic text not showing
1. Run `flutter pub get`
2. Restart the app
3. Check that `flutter_localizations` is in `pubspec.yaml`

**More troubleshooting:** See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

## 📝 Recent Changes

### v1.1.0 - API Integration
- ✅ Integrated real Laravel API
- ✅ Removed fake data
- ✅ Added loading states
- ✅ Added error handling
- ✅ Added pull-to-refresh
- ✅ Fixed Arabic localization

### v1.0.0 - Initial Release
- ✅ Basic UI with fake data
- ✅ Product listing
- ✅ Cart functionality
- ✅ Search and filters

## 🤝 Contributing

1. Get backend repository URL from your team
2. Follow setup guides
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📞 Support

If you encounter issues:
1. Check the documentation files
2. Test API endpoints in Postman
3. Check Laravel logs: `storage/logs/laravel.log`
4. Contact backend team for API issues

## 📄 License

Private project - Not for public distribution

---

**Made with ❤️ for fresh produce delivery**

## 🎯 Next Steps

1. ✅ Setup Laravel backend (see LARAVEL_SETUP_GUIDE.md)
2. ✅ Run `flutter pub get`
3. ✅ Configure API URL for your environment
4. ✅ Test the app
5. 🔄 Implement authentication
6. 🔄 Add order placement
7. 🔄 Add order tracking

**Happy Coding! 🚀**
