# 🎯 دليل استخدام المعمارية الجديدة

## ✅ تم الانتهاء من

تم إعادة هيكلة التطبيق بالكامل حسب **Clean Architecture** مع **Cubit**!

## 📁 الهيكل الجديد الصحيح

```
lib/
├── main.dart                    # نقطة البداية
├── injection_container.dart     # حقن التبعيات
│
├── core/                        # الأساسيات المشتركة
│   ├── api/
│   ├── error/
│   ├── network/
│   └── usecases/
│
└── features/                    # كل الميزات هنا ✅
    └── products/                # مثال: ميزة المنتجات
        ├── domain/              # المنطق
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        ├── data/                # البيانات
        │   ├── models/
        │   ├── datasources/
        │   └── repositories/
        └── presentation/        # العرض
            ├── cubit/
            ├── screens/
            └── widgets/
```

## 🔄 كيف تعمل المعمارية؟

### 1. الطبقات الثلاث

#### طبقة المنطق (Domain)
```dart
// entities/product.dart
class Product {
  final String id;
  final String nameAr;
  // ...
}

// repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}

// usecases/get_products.dart
class GetProducts {
  final ProductRepository repository;
  Future<Either<Failure, List<Product>>> call(params) {
    return repository.getProducts();
  }
}
```

#### طبقة البيانات (Data)
```dart
// models/product_model.dart
class ProductModel extends Product {
  factory ProductModel.fromJson(Map json) { ... }
  Map toJson() { ... }
}

// datasources/product_remote_datasource.dart
class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts() {
    // استدعاء API
  }
}

// repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts() {
    try {
      final products = await dataSource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

#### طبقة العرض (Presentation)
```dart
// cubit/products_state.dart
abstract class ProductsState {}
class ProductsLoading extends ProductsState {}
class ProductsLoaded extends ProductsState {
  final List<Product> products;
}
class ProductsError extends ProductsState {
  final String message;
}

// cubit/products_cubit.dart
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;
  
  Future<void> loadProducts() async {
    emit(ProductsLoading());
    final result = await getProducts(params);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }
}
```

### 2. استخدام Cubit في الشاشات

```dart
// screens/home_screen.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsCubit>()..loadProducts(),
      child: Scaffold(
        appBar: AppBar(title: Text('المنتجات')),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            // حالة التحميل
            if (state is ProductsLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            
            // حالة الخطأ
            if (state is ProductsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(state.message),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductsCubit>().loadProducts();
                      },
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            
            // حالة النجاح
            if (state is ProductsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<ProductsCubit>().refreshProducts();
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductCard(product: product);
                  },
                ),
              );
            }
            
            return SizedBox();
          },
        ),
        // زر البحث
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // فتح شاشة البحث
          },
          child: Icon(Icons.search),
        ),
      ),
    );
  }
}
```

### 3. العمليات المتاحة

```dart
// في أي مكان في الشاشة:
final cubit = context.read<ProductsCubit>();

// تحميل المنتجات
cubit.loadProducts();

// البحث
cubit.searchProducts('طماطم');

// تصفية حسب الفئة
cubit.filterByCategory(1);

// تحديث
cubit.refreshProducts();

// مسح التصفية
cubit.clearFilters();
```

## 🎨 مثال كامل: شاشة المنتجات

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../injection_container.dart' as di;
import '../features/products/presentation/cubit/products_cubit.dart';
import '../features/products/presentation/cubit/products_state.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductsCubit>()..loadProducts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المنتجات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: فتح شاشة البحث
              },
            ),
          ],
        ),
        body: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {
            // يمكنك عرض Snackbar عند حدوث خطأ
            if (state is ProductsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProductsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<ProductsCubit>().refreshProducts();
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nameAr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.price} ج.م / ${product.unit}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

## 📝 الخطوات التالية

1. **استبدل home_screen.dart** بالكود أعلاه
2. **أنشئ باقي الميزات** بنفس الطريقة
3. **احذف المجلدات القديمة** (models/, services/, screens/, widgets/)
4. **انقل كل شيء إلى features/**

## 🎯 الفوائد

✅ **منظم** - كل ميزة في مجلد منفصل  
✅ **قابل للاختبار** - سهل كتابة الاختبارات  
✅ **قابل للتوسع** - سهل إضافة ميزات جديدة  
✅ **احترافي** - معمارية صناعية معتمدة  

---

**الآن لديك معمارية احترافية! 🚀**
