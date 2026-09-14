import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injector.config.dart';

final getIt = GetIt.instance;

/// Đăng ký phụ thuộc. Mỗi feature tự khai báo API của mình bằng `@module`,
/// repository bằng `@LazySingleton(as: …)`, use case / cubit bằng `@injectable`.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
