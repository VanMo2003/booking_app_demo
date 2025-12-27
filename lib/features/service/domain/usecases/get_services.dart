import 'package:injectable/injectable.dart';

import '../entity/service.dart';
import '../repositories/service_repository.dart';

@injectable
class GetServices {
  final ServiceRepository repository;
  GetServices(this.repository);

  Future<List<ServiceEntity>> call({required int hotelId}) async =>
      await repository.getServices(hotelId: hotelId);
}
