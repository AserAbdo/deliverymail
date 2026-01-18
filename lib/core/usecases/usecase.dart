import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base Use Case Interface
/// واجهة حالة الاستخدام الأساسية
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No Parameters class for use cases that don't need parameters
/// فئة بدون معاملات لحالات الاستخدام التي لا تحتاج معاملات
class NoParams {
  const NoParams();
}
