# 🏗️ إعادة الهيكلة الكاملة - Clean Architecture + Cubit

## المشكلة الحالية

المعمارية الحالية **مختلطة وغير منظمة**:
- ❌ `models/`, `screens/`, `services/`, `widgets/` في الخارج
- ❌ لا يوجد state management (Cubit/Bloc)
- ❌ الملفات غير منظمة حسب الميزات
- ❌ لا يوجد فصل واضح بين الطبقات

## الهيكل الجديد الصحيح

```
lib/
├── main.dart
│
├── core/                                  # الأساسيات المشتركة
│   ├── api/
│   │   ├── api_client.dart
│   │   └── api_config.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── helpers.dart
│   └── theme/
│       └── app_theme.dart
│
└── features/                              # كل الميزات هنا
    │
    ├── auth/                              # ميزة المصادقة
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login.dart
    │   │       ├── register.dart
    │   │       └── logout.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── auth_cubit.dart
    │       │   └── auth_state.dart
    │       ├── screens/
    │       │   └── login_screen.dart
    │       └── widgets/
    │           ├── login_form.dart
    │           └── register_form.dart
    │
    ├── products/                          # ميزة المنتجات
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── product_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── product_model.dart
    │   │   └── repositories/
    │   │       └── product_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── product.dart
    │   │   ├── repositories/
    │   │   │   └── product_repository.dart
    │   │   └── usecases/
    │   │       ├── get_products.dart
    │   │       └── search_products.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── products_cubit.dart
    │       │   └── products_state.dart
    │       ├── screens/
    │       │   ├── home_screen.dart
    │       │   └── product_details_screen.dart
    │       └── widgets/
    │           └── product_card.dart
    │
    ├── categories/                        # ميزة الفئات
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── category_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── category_model.dart
    │   │   └── repositories/
    │   │       └── category_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── category.dart
    │   │   ├── repositories/
    │   │   │   └── category_repository.dart
    │   │   └── usecases/
    │   │       └── get_categories.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── categories_cubit.dart
    │       │   └── categories_state.dart
    │       ├── screens/
    │       │   └── categories_screen.dart
    │       └── widgets/
    │           └── category_chip.dart
    │
    ├── cart/                              # ميزة السلة
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── cart_local_datasource.dart
    │   │   ├── models/
    │   │   │   └── cart_item_model.dart
    │   │   └── repositories/
    │   │       └── cart_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── cart_item.dart
    │   │   ├── repositories/
    │   │   │   └── cart_repository.dart
    │   │   └── usecases/
    │   │       ├── add_to_cart.dart
    │   │       ├── remove_from_cart.dart
    │   │       └── get_cart_items.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── cart_cubit.dart
    │       │   └── cart_state.dart
    │       ├── screens/
    │       │   └── cart_screen.dart
    │       └── widgets/
    │           └── cart_item_widget.dart
    │
    ├── orders/                            # ميزة الطلبات
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── order_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── order_model.dart
    │   │   └── repositories/
    │   │       └── order_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── order.dart
    │   │   ├── repositories/
    │   │   │   └── order_repository.dart
    │   │   └── usecases/
    │   │       ├── create_order.dart
    │   │       ├── get_orders.dart
    │   │       └── get_order_details.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── orders_cubit.dart
    │       │   └── orders_state.dart
    │       ├── screens/
    │       │   ├── orders_screen.dart
    │       │   └── order_details_screen.dart
    │       └── widgets/
    │           └── order_card.dart
    │
    ├── profile/                           # ميزة الملف الشخصي
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── profile_cubit.dart
    │       │   └── profile_state.dart
    │       ├── screens/
    │       │   └── profile_screen.dart
    │       └── widgets/
    │           └── profile_menu_item.dart
    │
    └── splash/                            # شاشة البداية
        └── presentation/
            └── screens/
                └── splash_screen.dart
```

## الطبقات الثلاث (Clean Architecture)

### 1. Domain Layer (طبقة المنطق)
- **Entities**: الكيانات الأساسية (نماذج البيانات النقية)
- **Repositories**: واجهات المستودعات (abstract classes)
- **Use Cases**: حالات الاستخدام (كل عملية = use case)

### 2. Data Layer (طبقة البيانات)
- **Models**: نماذج البيانات مع fromJson/toJson
- **Data Sources**: مصادر البيانات (Remote/Local)
- **Repository Implementation**: تنفيذ المستودعات

### 3. Presentation Layer (طبقة العرض)
- **Cubit**: إدارة الحالة
- **Screens**: الشاشات
- **Widgets**: المكونات القابلة لإعادة الاستخدام

## State Management مع Cubit

### مثال: Products Cubit

```dart
// products_state.dart
abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  ProductsLoaded(this.products);
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

// products_cubit.dart
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;
  
  ProductsCubit({required this.getProducts}) : super(ProductsInitial());
  
  Future<void> loadProducts() async {
    emit(ProductsLoading());
    try {
      final products = await getProducts(NoParams());
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
```

## الحزم المطلوبة

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  injectable: ^2.3.2
```

## خطة التنفيذ

1. ✅ إضافة الحزم المطلوبة
2. ✅ إنشاء الهيكل الجديد
3. ✅ نقل الملفات وإعادة تنظيمها
4. ✅ إنشاء Cubits لكل ميزة
5. ✅ تحديث الـ imports
6. ✅ إعداد Dependency Injection
7. ✅ اختبار التطبيق

هل تريدني أن أبدأ التنفيذ الآن؟
