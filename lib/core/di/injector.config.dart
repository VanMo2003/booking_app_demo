// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:booking_app_mobile/core/di/network_module.dart' as _i186;
import 'package:booking_app_mobile/features/login/data/datasource/remote/login_api_service.dart'
    as _i651;
import 'package:booking_app_mobile/features/login/data/repository/login_repository_impl.dart'
    as _i290;
import 'package:booking_app_mobile/features/login/domain/repositories/auth_repository.dart'
    as _i510;
import 'package:booking_app_mobile/features/login/domain/usecases/login_use_case.dart'
    as _i624;
import 'package:booking_app_mobile/features/position/data/datasource/remote/position_api_service.dart'
    as _i277;
import 'package:booking_app_mobile/features/position/data/repository/position_repository_impl.dart'
    as _i548;
import 'package:booking_app_mobile/features/position/domain/repositories/position_repository.dart'
    as _i555;
import 'package:booking_app_mobile/features/position/domain/usecases/create_position.dart'
    as _i930;
import 'package:booking_app_mobile/features/position/domain/usecases/delete_position.dart'
    as _i352;
import 'package:booking_app_mobile/features/position/domain/usecases/get_positions.dart'
    as _i194;
import 'package:booking_app_mobile/features/position/domain/usecases/update_position.dart'
    as _i111;
import 'package:booking_app_mobile/features/room/data/datasource/remote/room_api_service.dart'
    as _i192;
import 'package:booking_app_mobile/features/room/data/repository/room_repository_impl.dart'
    as _i84;
import 'package:booking_app_mobile/features/room/domain/repositories/room_repository.dart'
    as _i77;
import 'package:booking_app_mobile/features/room/domain/usecases/create_room.dart'
    as _i41;
import 'package:booking_app_mobile/features/room/domain/usecases/delete_room.dart'
    as _i480;
import 'package:booking_app_mobile/features/room/domain/usecases/get_rooms.dart'
    as _i503;
import 'package:booking_app_mobile/features/room/domain/usecases/update_room.dart'
    as _i737;
import 'package:booking_app_mobile/features/room_type/data/datasource/remote/room_type_api_service.dart'
    as _i244;
import 'package:booking_app_mobile/features/room_type/data/repository/room_type_repository_impl.dart'
    as _i559;
import 'package:booking_app_mobile/features/room_type/domain/repositories/room_type_repository.dart'
    as _i18;
import 'package:booking_app_mobile/features/room_type/domain/usecases/create_room_type.dart'
    as _i526;
import 'package:booking_app_mobile/features/room_type/domain/usecases/delete_room_type.dart'
    as _i117;
import 'package:booking_app_mobile/features/room_type/domain/usecases/get_room_types.dart'
    as _i592;
import 'package:booking_app_mobile/features/room_type/domain/usecases/update_room_type.dart'
    as _i771;
import 'package:booking_app_mobile/features/service/data/datasource/remote/service_api_service.dart'
    as _i267;
import 'package:booking_app_mobile/features/service/data/repository/service_repository_impl.dart'
    as _i704;
import 'package:booking_app_mobile/features/service/domain/repositories/service_repository.dart'
    as _i820;
import 'package:booking_app_mobile/features/service/domain/usecases/create_service.dart'
    as _i171;
import 'package:booking_app_mobile/features/service/domain/usecases/delete_service.dart'
    as _i161;
import 'package:booking_app_mobile/features/service/domain/usecases/get_services.dart'
    as _i329;
import 'package:booking_app_mobile/features/service/domain/usecases/update_service.dart'
    as _i482;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i651.LoginApiService>(
        () => networkModule.provideLoanPackageApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i277.PositionApiService>(
        () => networkModule.providePositionApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i244.RoomTypeApiService>(
        () => networkModule.provideRoomTypeApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i192.RoomApiService>(
        () => networkModule.provideRoomApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i267.ServiceApiService>(
        () => networkModule.provideServiceApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i555.PositionRepository>(
        () => _i548.PositionRepositoryImpl(gh<_i277.PositionApiService>()));
    gh.factory<_i930.CreatePosition>(
        () => _i930.CreatePosition(gh<_i555.PositionRepository>()));
    gh.factory<_i352.DeletePosition>(
        () => _i352.DeletePosition(gh<_i555.PositionRepository>()));
    gh.factory<_i194.GetPositions>(
        () => _i194.GetPositions(gh<_i555.PositionRepository>()));
    gh.factory<_i111.UpdatePosition>(
        () => _i111.UpdatePosition(gh<_i555.PositionRepository>()));
    gh.lazySingleton<_i820.ServiceRepository>(
        () => _i704.ServiceRepositoryImpl(gh<_i267.ServiceApiService>()));
    gh.lazySingleton<_i510.AuthRepository>(
        () => _i290.AuthRepositoryImpl(gh<_i651.LoginApiService>()));
    gh.factory<_i171.CreateService>(
        () => _i171.CreateService(gh<_i820.ServiceRepository>()));
    gh.factory<_i161.DeleteService>(
        () => _i161.DeleteService(gh<_i820.ServiceRepository>()));
    gh.factory<_i329.GetServices>(
        () => _i329.GetServices(gh<_i820.ServiceRepository>()));
    gh.factory<_i482.UpdateService>(
        () => _i482.UpdateService(gh<_i820.ServiceRepository>()));
    gh.factory<_i624.LoginUseCase>(
        () => _i624.LoginUseCase(gh<_i510.AuthRepository>()));
    gh.lazySingleton<_i77.RoomRepository>(
        () => _i84.RoomRepositoryImpl(gh<_i192.RoomApiService>()));
    gh.lazySingleton<_i18.RoomTypeRepository>(
        () => _i559.RoomTypeRepositoryImpl(gh<_i244.RoomTypeApiService>()));
    gh.factory<_i526.CreateRoomType>(
        () => _i526.CreateRoomType(gh<_i18.RoomTypeRepository>()));
    gh.factory<_i117.DeleteRoomType>(
        () => _i117.DeleteRoomType(gh<_i18.RoomTypeRepository>()));
    gh.factory<_i592.GetRoomTypes>(
        () => _i592.GetRoomTypes(gh<_i18.RoomTypeRepository>()));
    gh.factory<_i771.UpdateRoomType>(
        () => _i771.UpdateRoomType(gh<_i18.RoomTypeRepository>()));
    gh.factory<_i41.CreateRoom>(
        () => _i41.CreateRoom(gh<_i77.RoomRepository>()));
    gh.factory<_i480.DeleteRoom>(
        () => _i480.DeleteRoom(gh<_i77.RoomRepository>()));
    gh.factory<_i503.GetRooms>(() => _i503.GetRooms(gh<_i77.RoomRepository>()));
    gh.factory<_i737.UpdateRoom>(
        () => _i737.UpdateRoom(gh<_i77.RoomRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i186.NetworkModule {}
