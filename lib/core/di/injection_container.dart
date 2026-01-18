import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';

/// Service Locator - Dependency Injection
/// محدد الخدمات - حقن التبعيات
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Products

  // Cubit
  sl.registerFactory(() => ProductsCubit(getProducts: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core

  // API Client
  sl.registerLazySingleton(
    () => ApiClient(baseUrl: ApiConfig.baseUrl, headers: ApiConfig.headers),
  );

  // You can add more features here following the same pattern
  // يمكنك إضافة المزيد من الميزات هنا باتباع نفس النمط
}
