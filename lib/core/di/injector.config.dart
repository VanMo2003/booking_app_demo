// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:booking_app_mobile/core/di/network_module.dart' as _i186;
import 'package:booking_app_mobile/features/auth/data/datasource/remote/login_api_service.dart'
    as _i10;
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
    gh.lazySingleton<_i10.LoginApiService>(
        () => networkModule.provideLoanPackageApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i277.PositionApiService>(
        () => networkModule.providePositionApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i244.RoomTypeApiService>(
        () => networkModule.provideRoomTypeApiService(gh<_i361.Dio>()));
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
    return this;
  }
}

class _$NetworkModule extends _i186.NetworkModule {}
