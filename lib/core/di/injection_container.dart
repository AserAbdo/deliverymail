import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
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
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core

  // API Client - with baseUrl from ApiConstants
  sl.registerLazySingleton(() => ApiClient(baseUrl: ApiConstants.baseUrl));

  // You can add more features here following the same pattern
  // يمكنك إضافة المزيد من الميزات هنا باتباع نفس النمط
}
