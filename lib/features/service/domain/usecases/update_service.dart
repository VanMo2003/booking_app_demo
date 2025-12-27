import 'package:injectable/injectable.dart';

import '../entity/service.dart';
import '../repositories/service_repository.dart';

@injectable
class UpdateService {
  final ServiceRepository repository;
  UpdateService(this.repository);

  Future<ServiceEntity> call(ServiceEntity service) async =>
      await repository.updateService(service);
}
