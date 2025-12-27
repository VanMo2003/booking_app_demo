import 'package:injectable/injectable.dart';

import '../entity/service.dart';
import '../repositories/service_repository.dart';

@injectable
class CreateService {
  final ServiceRepository repository;
  CreateService(this.repository);

  Future<ServiceEntity> call(ServiceEntity service) async =>
      await repository.createService(service);
}
