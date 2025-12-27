import 'package:injectable/injectable.dart';

import '../repositories/service_repository.dart';

@injectable
class DeleteService {
  final ServiceRepository repository;
  DeleteService(this.repository);

  Future<void> call(int id) async => await repository.deleteService(id);
}
