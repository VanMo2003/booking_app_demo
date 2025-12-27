import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/service.dart';
import '../../domain/usecases/get_services.dart';
import '../../domain/usecases/create_service.dart';
import '../../domain/usecases/update_service.dart';
import '../../domain/usecases/delete_service.dart';

part 'service_state.dart';
part 'service_cubit.freezed.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final GetServices getServices;
  final CreateService createService;
  final UpdateService updateService;
  final DeleteService deleteService;

  ServiceCubit({
    required this.getServices,
    required this.createService,
    required this.updateService,
    required this.deleteService,
  }) : super(const ServiceState());

  Future<void> fetch({required int hotelId}) async {
    try {
      emit(state.copyWith(status: ServiceStatus.loading));
      final items = await getServices.call(hotelId: hotelId);
      emit(state.copyWith(status: ServiceStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> add(ServiceEntity s) async {
    try {
      emit(state.copyWith(status: ServiceStatus.loading));
      final created = await createService.call(s);
      final current = state.items?.toList() ?? [];
      current.add(created);
      emit(state.copyWith(status: ServiceStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> edit(ServiceEntity s) async {
    try {
      emit(state.copyWith(status: ServiceStatus.loading));
      final updated = await updateService.call(s);
      final current =
          state.items?.map((it) => it.id == updated.id ? updated : it).toList();
      emit(state.copyWith(status: ServiceStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> remove(int id) async {
    try {
      emit(state.copyWith(status: ServiceStatus.loading));
      await deleteService.call(id);
      final current = state.items?.where((it) => it.id != id).toList();
      emit(state.copyWith(status: ServiceStatus.success, items: current));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
