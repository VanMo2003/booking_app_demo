// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:booking_app_mobile/core/di/app_module.dart' as _i732;
import 'package:booking_app_mobile/core/network/network_status.dart' as _i820;
import 'package:booking_app_mobile/core/network/session_events.dart' as _i432;
import 'package:booking_app_mobile/core/storage/app_preferences.dart' as _i774;
import 'package:booking_app_mobile/core/storage/token_storage.dart' as _i991;
import 'package:booking_app_mobile/features/account/data/datasources/account_api.dart'
    as _i458;
import 'package:booking_app_mobile/features/account/data/repositories/account_repository_impl.dart'
    as _i767;
import 'package:booking_app_mobile/features/account/domain/repositories/account_repository.dart'
    as _i654;
import 'package:booking_app_mobile/features/account/domain/usecases/account_usecases.dart'
    as _i275;
import 'package:booking_app_mobile/features/admin/domain/usecases/load_system_overview.dart'
    as _i962;
import 'package:booking_app_mobile/features/admin/presentation/accounts_screen.dart'
    as _i770;
import 'package:booking_app_mobile/features/admin/presentation/admin_overview_screen.dart'
    as _i1048;
import 'package:booking_app_mobile/features/admin/presentation/catalog_screen.dart'
    as _i1018;
import 'package:booking_app_mobile/features/admin/presentation/owner_approvals_screen.dart'
    as _i922;
import 'package:booking_app_mobile/features/admin/presentation/owner_registration_detail_screen.dart'
    as _i750;
import 'package:booking_app_mobile/features/admin/presentation/system_data_screen.dart'
    as _i489;
import 'package:booking_app_mobile/features/ai/data/datasources/ai_api.dart'
    as _i431;
import 'package:booking_app_mobile/features/ai/data/repositories/ai_repository_impl.dart'
    as _i993;
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart'
    as _i444;
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart'
    as _i769;
import 'package:booking_app_mobile/features/ai/presentation/ai_search_screen.dart'
    as _i1050;
import 'package:booking_app_mobile/features/amenity/data/datasources/amenity_api.dart'
    as _i619;
import 'package:booking_app_mobile/features/amenity/data/repositories/amenity_repository_impl.dart'
    as _i408;
import 'package:booking_app_mobile/features/amenity/domain/repositories/amenity_repository.dart'
    as _i214;
import 'package:booking_app_mobile/features/amenity/domain/usecases/amenity_usecases.dart'
    as _i961;
import 'package:booking_app_mobile/features/auth/data/datasources/auth_api.dart'
    as _i165;
import 'package:booking_app_mobile/features/auth/data/datasources/session_local_data_source.dart'
    as _i624;
import 'package:booking_app_mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i535;
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i619;
import 'package:booking_app_mobile/features/auth/domain/usecases/auth_usecases.dart'
    as _i856;
import 'package:booking_app_mobile/features/auth/presentation/login/login_cubit.dart'
    as _i836;
import 'package:booking_app_mobile/features/auth/presentation/profile_setup/profile_setup_cubit.dart'
    as _i388;
import 'package:booking_app_mobile/features/auth/presentation/session/session_cubit.dart'
    as _i642;
import 'package:booking_app_mobile/features/booking/data/datasources/booking_api.dart'
    as _i691;
import 'package:booking_app_mobile/features/booking/data/repositories/booking_repository_impl.dart'
    as _i1028;
import 'package:booking_app_mobile/features/booking/domain/repositories/booking_repository.dart'
    as _i299;
import 'package:booking_app_mobile/features/booking/domain/usecases/booking_usecases.dart'
    as _i750;
import 'package:booking_app_mobile/features/booking/presentation/create/booking_create_cubit.dart'
    as _i625;
import 'package:booking_app_mobile/features/booking/presentation/desk/desk_cubit.dart'
    as _i534;
import 'package:booking_app_mobile/features/booking/presentation/detail/booking_detail_cubit.dart'
    as _i287;
import 'package:booking_app_mobile/features/booking/presentation/edit/booking_edit_screen.dart'
    as _i1027;
import 'package:booking_app_mobile/features/booking/presentation/my_bookings/my_bookings_screen.dart'
    as _i811;
import 'package:booking_app_mobile/features/booking/presentation/walk_in/walk_in_guest_cubit.dart'
    as _i209;
import 'package:booking_app_mobile/features/catalog/data/datasources/catalog_api.dart'
    as _i477;
import 'package:booking_app_mobile/features/catalog/data/repositories/catalog_repository_impl.dart'
    as _i682;
import 'package:booking_app_mobile/features/catalog/domain/repositories/catalog_repository.dart'
    as _i128;
import 'package:booking_app_mobile/features/catalog/domain/usecases/catalog_usecases.dart'
    as _i1061;
import 'package:booking_app_mobile/features/chat/data/datasources/chat_api.dart'
    as _i204;
import 'package:booking_app_mobile/features/chat/data/repositories/chat_repository_impl.dart'
    as _i375;
import 'package:booking_app_mobile/features/chat/domain/repositories/chat_repository.dart'
    as _i702;
import 'package:booking_app_mobile/features/chat/domain/usecases/chat_usecases.dart'
    as _i209;
import 'package:booking_app_mobile/features/chat/presentation/chat/chat_cubit.dart'
    as _i158;
import 'package:booking_app_mobile/features/chat/presentation/chat_hub.dart'
    as _i493;
import 'package:booking_app_mobile/features/chat/presentation/inbox/conversations_cubit.dart'
    as _i932;
import 'package:booking_app_mobile/features/chat/services/chat_socket.dart'
    as _i485;
import 'package:booking_app_mobile/features/customer/data/datasources/customer_api.dart'
    as _i294;
import 'package:booking_app_mobile/features/customer/data/repositories/customer_repository_impl.dart'
    as _i339;
import 'package:booking_app_mobile/features/customer/domain/repositories/customer_repository.dart'
    as _i939;
import 'package:booking_app_mobile/features/customer/domain/usecases/customer_usecases.dart'
    as _i57;
import 'package:booking_app_mobile/features/customer/presentation/branch/branch_customers_screen.dart'
    as _i999;
import 'package:booking_app_mobile/features/customer/presentation/branch/customer_detail_screen.dart'
    as _i823;
import 'package:booking_app_mobile/features/dish/data/datasources/dish_api.dart'
    as _i725;
import 'package:booking_app_mobile/features/dish/data/repositories/dish_repository_impl.dart'
    as _i758;
import 'package:booking_app_mobile/features/dish/domain/repositories/dish_repository.dart'
    as _i941;
import 'package:booking_app_mobile/features/dish/domain/usecases/dish_usecases.dart'
    as _i643;
import 'package:booking_app_mobile/features/dish/presentation/dishes_cubit.dart'
    as _i1003;
import 'package:booking_app_mobile/features/employee/data/datasources/employee_api.dart'
    as _i618;
import 'package:booking_app_mobile/features/employee/data/repositories/employee_repository_impl.dart'
    as _i71;
import 'package:booking_app_mobile/features/employee/domain/repositories/employee_repository.dart'
    as _i83;
import 'package:booking_app_mobile/features/employee/domain/usecases/employee_usecases.dart'
    as _i320;
import 'package:booking_app_mobile/features/employee/presentation/employees_screen.dart'
    as _i41;
import 'package:booking_app_mobile/features/favorite/data/favorite_store.dart'
    as _i412;
import 'package:booking_app_mobile/features/favorite/presentation/favorites_cubit.dart'
    as _i329;
import 'package:booking_app_mobile/features/feedback/data/datasources/feedback_api.dart'
    as _i621;
import 'package:booking_app_mobile/features/feedback/data/repositories/feedback_repository_impl.dart'
    as _i267;
import 'package:booking_app_mobile/features/feedback/domain/repositories/feedback_repository.dart'
    as _i900;
import 'package:booking_app_mobile/features/feedback/domain/usecases/feedback_usecases.dart'
    as _i406;
import 'package:booking_app_mobile/features/hotel/data/datasources/hotel_api.dart'
    as _i1009;
import 'package:booking_app_mobile/features/hotel/data/repositories/hotel_repository_impl.dart'
    as _i48;
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart'
    as _i16;
import 'package:booking_app_mobile/features/hotel/domain/usecases/hotel_usecases.dart'
    as _i672;
import 'package:booking_app_mobile/features/hotel/presentation/branch/branch_cubit.dart'
    as _i728;
import 'package:booking_app_mobile/features/hotel/presentation/detail/hotel_detail_cubit.dart'
    as _i1019;
import 'package:booking_app_mobile/features/hotel/presentation/explore/explore_cubit.dart'
    as _i187;
import 'package:booking_app_mobile/features/hotel/presentation/search/search_results_screen.dart'
    as _i98;
import 'package:booking_app_mobile/features/hotel_chain/data/datasources/hotel_chain_api.dart'
    as _i502;
import 'package:booking_app_mobile/features/hotel_chain/data/manager_registry.dart'
    as _i232;
import 'package:booking_app_mobile/features/hotel_chain/data/repositories/hotel_chain_repository_impl.dart'
    as _i430;
import 'package:booking_app_mobile/features/hotel_chain/domain/repositories/hotel_chain_repository.dart'
    as _i1057;
import 'package:booking_app_mobile/features/hotel_chain/domain/usecases/hotel_chain_usecases.dart'
    as _i782;
import 'package:booking_app_mobile/features/hotel_chain/presentation/chain_cubits.dart'
    as _i1;
import 'package:booking_app_mobile/features/notification/data/datasources/notification_api.dart'
    as _i367;
import 'package:booking_app_mobile/features/notification/data/repositories/notification_repository_impl.dart'
    as _i247;
import 'package:booking_app_mobile/features/notification/domain/repositories/notification_repository.dart'
    as _i129;
import 'package:booking_app_mobile/features/notification/domain/usecases/notification_usecases.dart'
    as _i398;
import 'package:booking_app_mobile/features/notification/presentation/notification_badge_cubit.dart'
    as _i534;
import 'package:booking_app_mobile/features/notification/presentation/notifications_screen.dart'
    as _i25;
import 'package:booking_app_mobile/features/notification/services/deep_link_service.dart'
    as _i847;
import 'package:booking_app_mobile/features/notification/services/notification_events.dart'
    as _i622;
import 'package:booking_app_mobile/features/notification/services/push_service.dart'
    as _i966;
import 'package:booking_app_mobile/features/partner/data/datasources/partner_api.dart'
    as _i635;
import 'package:booking_app_mobile/features/partner/data/repositories/partner_repository_impl.dart'
    as _i867;
import 'package:booking_app_mobile/features/partner/domain/repositories/partner_repository.dart'
    as _i479;
import 'package:booking_app_mobile/features/partner/domain/usecases/partner_usecases.dart'
    as _i387;
import 'package:booking_app_mobile/features/partner/presentation/owner_register_cubit.dart'
    as _i1026;
import 'package:booking_app_mobile/features/payment/data/datasources/payment_api.dart'
    as _i219;
import 'package:booking_app_mobile/features/payment/data/repositories/payment_repository_impl.dart'
    as _i1070;
import 'package:booking_app_mobile/features/payment/domain/repositories/payment_repository.dart'
    as _i545;
import 'package:booking_app_mobile/features/payment/domain/usecases/payment_usecases.dart'
    as _i854;
import 'package:booking_app_mobile/features/payroll/data/datasources/payroll_api.dart'
    as _i981;
import 'package:booking_app_mobile/features/payroll/data/payroll_session_store.dart'
    as _i381;
import 'package:booking_app_mobile/features/payroll/data/repositories/payroll_repository_impl.dart'
    as _i65;
import 'package:booking_app_mobile/features/payroll/domain/repositories/payroll_repository.dart'
    as _i625;
import 'package:booking_app_mobile/features/payroll/domain/usecases/payroll_usecases.dart'
    as _i134;
import 'package:booking_app_mobile/features/payroll/presentation/payroll_screen.dart'
    as _i102;
import 'package:booking_app_mobile/features/report/data/datasources/report_remote_data_source.dart'
    as _i797;
import 'package:booking_app_mobile/features/report/data/repositories/report_repository_impl.dart'
    as _i903;
import 'package:booking_app_mobile/features/report/domain/repositories/report_repository.dart'
    as _i12;
import 'package:booking_app_mobile/features/report/domain/usecases/report_usecases.dart'
    as _i109;
import 'package:booking_app_mobile/features/report/presentation/dashboard/dashboard_screen.dart'
    as _i79;
import 'package:booking_app_mobile/features/report/presentation/reports/reports_cubit.dart'
    as _i978;
import 'package:booking_app_mobile/features/room/data/datasources/room_api.dart'
    as _i679;
import 'package:booking_app_mobile/features/room/data/repositories/room_repository_impl.dart'
    as _i968;
import 'package:booking_app_mobile/features/room/domain/repositories/room_repository.dart'
    as _i77;
import 'package:booking_app_mobile/features/room/domain/usecases/room_usecases.dart'
    as _i643;
import 'package:booking_app_mobile/features/room/presentation/detail/room_detail_cubit.dart'
    as _i955;
import 'package:booking_app_mobile/features/room/presentation/manage/room_manage_detail_screen.dart'
    as _i785;
import 'package:booking_app_mobile/features/room/presentation/manage/rooms_manage_screen.dart'
    as _i508;
import 'package:booking_app_mobile/features/service/data/datasources/service_api.dart'
    as _i17;
import 'package:booking_app_mobile/features/service/data/repositories/hotel_service_repository_impl.dart'
    as _i262;
import 'package:booking_app_mobile/features/service/domain/repositories/hotel_service_repository.dart'
    as _i324;
import 'package:booking_app_mobile/features/service/domain/usecases/hotel_service_usecases.dart'
    as _i358;
import 'package:booking_app_mobile/features/service/presentation/services_screen.dart'
    as _i1049;
import 'package:booking_app_mobile/features/tour/data/datasources/tour_api.dart'
    as _i424;
import 'package:booking_app_mobile/features/tour/data/datasources/tour_booking_api.dart'
    as _i497;
import 'package:booking_app_mobile/features/tour/data/repositories/tour_booking_repository_impl.dart'
    as _i856;
import 'package:booking_app_mobile/features/tour/data/repositories/tour_repository_impl.dart'
    as _i697;
import 'package:booking_app_mobile/features/tour/domain/repositories/tour_booking_repository.dart'
    as _i695;
import 'package:booking_app_mobile/features/tour/domain/repositories/tour_repository.dart'
    as _i954;
import 'package:booking_app_mobile/features/tour/domain/usecases/tour_booking_usecases.dart'
    as _i987;
import 'package:booking_app_mobile/features/tour/domain/usecases/tour_usecases.dart'
    as _i1001;
import 'package:booking_app_mobile/features/tour/presentation/bookings/tour_booking_detail_screen.dart'
    as _i747;
import 'package:booking_app_mobile/features/tour/presentation/bookings/tour_bookings_screen.dart'
    as _i420;
import 'package:booking_app_mobile/features/tour/presentation/tours_screen.dart'
    as _i203;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    final accountApiModule = _$AccountApiModule();
    final amenityApiModule = _$AmenityApiModule();
    final authApiModule = _$AuthApiModule();
    final bookingApiModule = _$BookingApiModule();
    final catalogApiModule = _$CatalogApiModule();
    final customerApiModule = _$CustomerApiModule();
    final employeeApiModule = _$EmployeeApiModule();
    final feedbackApiModule = _$FeedbackApiModule();
    final hotelApiModule = _$HotelApiModule();
    final hotelChainApiModule = _$HotelChainApiModule();
    final notificationApiModule = _$NotificationApiModule();
    final partnerApiModule = _$PartnerApiModule();
    final paymentApiModule = _$PaymentApiModule();
    final payrollApiModule = _$PayrollApiModule();
    final roomApiModule = _$RoomApiModule();
    final serviceApiModule = _$ServiceApiModule();
    final dishApiModule = _$DishApiModule();
    final chatApiModule = _$ChatApiModule();
    final aiApiModule = _$AiApiModule();
    final tourApiModule = _$TourApiModule();
    final tourBookingApiModule = _$TourBookingApiModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i895.Connectivity>(() => appModule.connectivity);
    gh.lazySingleton<_i432.SessionEvents>(
      () => _i432.SessionEvents(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i847.DeepLinkService>(() => _i847.DeepLinkService());
    gh.lazySingleton<_i622.NotificationEvents>(
        () => _i622.NotificationEvents());
    gh.lazySingleton<_i381.PayrollSessionStore>(
        () => _i381.PayrollSessionStore());
    gh.lazySingleton<_i774.AppPreferences>(
        () => _i774.AppPreferences(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i991.TokenStorage>(
        () => _i991.TokenStorage(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i624.SessionLocalDataSource>(
        () => _i624.SessionLocalDataSource(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i820.NetworkStatus>(
        () => _i820.NetworkStatus(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i485.ChatSocket>(
        () => _i485.ChatSocket(gh<_i991.TokenStorage>()));
    gh.lazySingleton<_i412.FavoriteStore>(
        () => _i412.FavoriteStore(gh<_i774.AppPreferences>()));
    gh.lazySingleton<_i232.ManagerRegistry>(
        () => _i232.ManagerRegistry(gh<_i774.AppPreferences>()));
    gh.lazySingleton<_i361.Dio>(() => appModule.dio(
          gh<_i991.TokenStorage>(),
          gh<_i432.SessionEvents>(),
          gh<_i820.NetworkStatus>(),
        ));
    gh.lazySingleton<_i458.AccountApi>(
        () => accountApiModule.accountApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i619.AmenityApi>(
        () => amenityApiModule.amenityApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i165.AuthApi>(
        () => authApiModule.authApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i691.BookingApi>(
        () => bookingApiModule.bookingApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i477.CatalogApi>(
        () => catalogApiModule.catalogApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i294.CustomerApi>(
        () => customerApiModule.customerApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i618.EmployeeApi>(
        () => employeeApiModule.employeeApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i621.FeedbackApi>(
        () => feedbackApiModule.feedbackApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i1009.HotelApi>(
        () => hotelApiModule.hotelApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i502.HotelChainApi>(
        () => hotelChainApiModule.hotelChainApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i367.NotificationApi>(
        () => notificationApiModule.notificationApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i635.PartnerApi>(
        () => partnerApiModule.partnerApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i219.PaymentApi>(
        () => paymentApiModule.paymentApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i981.PayrollApi>(
        () => payrollApiModule.payrollApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i679.RoomApi>(
        () => roomApiModule.roomApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i17.ServiceApi>(
        () => serviceApiModule.serviceApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i725.DishApi>(
        () => dishApiModule.dishApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i204.ChatApi>(
        () => chatApiModule.chatApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i431.AiApi>(() => aiApiModule.aiApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i424.TourApi>(
        () => tourApiModule.tourApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i497.TourBookingApi>(
        () => tourBookingApiModule.tourBookingApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i479.PartnerRepository>(
        () => _i867.PartnerRepositoryImpl(gh<_i635.PartnerApi>()));
    gh.lazySingleton<_i797.ReportRemoteDataSource>(
        () => _i797.ReportRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i954.TourRepository>(
        () => _i697.TourRepositoryImpl(gh<_i424.TourApi>()));
    gh.lazySingleton<_i900.FeedbackRepository>(
        () => _i267.FeedbackRepositoryImpl(
              gh<_i621.FeedbackApi>(),
              gh<_i774.AppPreferences>(),
            ));
    gh.lazySingleton<_i619.AuthRepository>(() => _i535.AuthRepositoryImpl(
          gh<_i165.AuthApi>(),
          gh<_i991.TokenStorage>(),
          gh<_i624.SessionLocalDataSource>(),
        ));
    gh.lazySingleton<_i16.HotelRepository>(
        () => _i48.HotelRepositoryImpl(gh<_i1009.HotelApi>()));
    gh.factory<_i672.GetHotelsPage>(
        () => _i672.GetHotelsPage(gh<_i16.HotelRepository>()));
    gh.factory<_i672.GetAllHotels>(
        () => _i672.GetAllHotels(gh<_i16.HotelRepository>()));
    gh.factory<_i672.GetHotelsByCategory>(
        () => _i672.GetHotelsByCategory(gh<_i16.HotelRepository>()));
    gh.factory<_i672.SearchAvailableHotels>(
        () => _i672.SearchAvailableHotels(gh<_i16.HotelRepository>()));
    gh.factory<_i672.GetHotelDetail>(
        () => _i672.GetHotelDetail(gh<_i16.HotelRepository>()));
    gh.factory<_i672.GetManagedHotels>(
        () => _i672.GetManagedHotels(gh<_i16.HotelRepository>()));
    gh.factory<_i672.CreateBranch>(
        () => _i672.CreateBranch(gh<_i16.HotelRepository>()));
    gh.factory<_i672.UpdateBranch>(
        () => _i672.UpdateBranch(gh<_i16.HotelRepository>()));
    gh.factory<_i672.SetBranchActive>(
        () => _i672.SetBranchActive(gh<_i16.HotelRepository>()));
    gh.factory<_i672.DeleteBranch>(
        () => _i672.DeleteBranch(gh<_i16.HotelRepository>()));
    gh.factory<_i672.UploadBranchImages>(
        () => _i672.UploadBranchImages(gh<_i16.HotelRepository>()));
    gh.factory<_i1001.GetBranchTours>(
        () => _i1001.GetBranchTours(gh<_i954.TourRepository>()));
    gh.factory<_i1001.SaveTour>(
        () => _i1001.SaveTour(gh<_i954.TourRepository>()));
    gh.factory<_i1001.SetTourAvailable>(
        () => _i1001.SetTourAvailable(gh<_i954.TourRepository>()));
    gh.factory<_i1001.DeleteTour>(
        () => _i1001.DeleteTour(gh<_i954.TourRepository>()));
    gh.factory<_i856.RefreshManagerBranches>(
        () => _i856.RefreshManagerBranches(gh<_i16.HotelRepository>()));
    gh.lazySingleton<_i128.CatalogRepository>(
        () => _i682.CatalogRepositoryImpl(gh<_i477.CatalogApi>()));
    gh.factory<_i203.ToursCubit>(
        () => _i203.ToursCubit(gh<_i1001.GetBranchTours>()));
    gh.factory<_i856.Login>(() => _i856.Login(gh<_i619.AuthRepository>()));
    gh.factory<_i856.RegisterCustomer>(
        () => _i856.RegisterCustomer(gh<_i619.AuthRepository>()));
    gh.factory<_i856.Logout>(() => _i856.Logout(gh<_i619.AuthRepository>()));
    gh.factory<_i856.RestoreSession>(
        () => _i856.RestoreSession(gh<_i619.AuthRepository>()));
    gh.factory<_i856.PersistSession>(
        () => _i856.PersistSession(gh<_i619.AuthRepository>()));
    gh.lazySingleton<_i324.HotelServiceRepository>(
        () => _i262.HotelServiceRepositoryImpl(gh<_i17.ServiceApi>()));
    gh.lazySingleton<_i214.AmenityRepository>(
        () => _i408.AmenityRepositoryImpl(gh<_i619.AmenityApi>()));
    gh.lazySingleton<_i299.BookingRepository>(
        () => _i1028.BookingRepositoryImpl(gh<_i691.BookingApi>()));
    gh.factory<_i98.SearchResultsCubit>(
        () => _i98.SearchResultsCubit(gh<_i672.SearchAvailableHotels>()));
    gh.lazySingleton<_i702.ChatRepository>(
        () => _i375.ChatRepositoryImpl(gh<_i204.ChatApi>()));
    gh.factory<_i961.GetRoomAmenities>(
        () => _i961.GetRoomAmenities(gh<_i214.AmenityRepository>()));
    gh.factory<_i961.CreateAmenity>(
        () => _i961.CreateAmenity(gh<_i214.AmenityRepository>()));
    gh.factory<_i961.UpdateAmenity>(
        () => _i961.UpdateAmenity(gh<_i214.AmenityRepository>()));
    gh.factory<_i961.DeleteAmenity>(
        () => _i961.DeleteAmenity(gh<_i214.AmenityRepository>()));
    gh.factory<_i961.LinkAmenityToRoom>(
        () => _i961.LinkAmenityToRoom(gh<_i214.AmenityRepository>()));
    gh.lazySingleton<_i83.EmployeeRepository>(
        () => _i71.EmployeeRepositoryImpl(gh<_i618.EmployeeApi>()));
    gh.lazySingleton<_i941.DishRepository>(
        () => _i758.DishRepositoryImpl(gh<_i725.DishApi>()));
    gh.factory<_i489.BranchesPageCubit>(
        () => _i489.BranchesPageCubit(gh<_i672.GetHotelsPage>()));
    gh.factory<_i406.SubmitReview>(
        () => _i406.SubmitReview(gh<_i900.FeedbackRepository>()));
    gh.factory<_i406.IsBookingReviewed>(
        () => _i406.IsBookingReviewed(gh<_i900.FeedbackRepository>()));
    gh.lazySingleton<_i1057.HotelChainRepository>(
        () => _i430.HotelChainRepositoryImpl(gh<_i502.HotelChainApi>()));
    gh.factory<_i387.RegisterOwner>(
        () => _i387.RegisterOwner(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.RefreshOwnerStatus>(
        () => _i387.RefreshOwnerStatus(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.ResubmitOwnerProfile>(
        () => _i387.ResubmitOwnerProfile(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.GetOwnerRegistrations>(
        () => _i387.GetOwnerRegistrations(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.GetOwnerRegistration>(
        () => _i387.GetOwnerRegistration(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.ApproveOwner>(
        () => _i387.ApproveOwner(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.RejectOwner>(
        () => _i387.RejectOwner(gh<_i479.PartnerRepository>()));
    gh.factory<_i387.CountPendingOwners>(
        () => _i387.CountPendingOwners(gh<_i479.PartnerRepository>()));
    gh.lazySingleton<_i12.ReportRepository>(
        () => _i903.ReportRepositoryImpl(gh<_i797.ReportRemoteDataSource>()));
    gh.lazySingleton<_i444.AiRepository>(
        () => _i993.AiRepositoryImpl(gh<_i431.AiApi>()));
    gh.lazySingleton<_i545.PaymentRepository>(
        () => _i1070.PaymentRepositoryImpl(gh<_i219.PaymentApi>()));
    gh.lazySingleton<_i625.PayrollRepository>(
        () => _i65.PayrollRepositoryImpl(gh<_i981.PayrollApi>()));
    gh.lazySingleton<_i939.CustomerRepository>(
        () => _i339.CustomerRepositoryImpl(gh<_i294.CustomerApi>()));
    gh.lazySingleton<_i642.SessionCubit>(() => _i642.SessionCubit(
          gh<_i856.RestoreSession>(),
          gh<_i856.Logout>(),
          gh<_i856.PersistSession>(),
          gh<_i432.SessionEvents>(),
        ));
    gh.lazySingleton<_i654.AccountRepository>(
        () => _i767.AccountRepositoryImpl(gh<_i458.AccountApi>()));
    gh.factory<_i1061.GetCatalog>(
        () => _i1061.GetCatalog(gh<_i128.CatalogRepository>()));
    gh.factory<_i1061.SaveCatalogItem>(
        () => _i1061.SaveCatalogItem(gh<_i128.CatalogRepository>()));
    gh.factory<_i1061.DeleteCatalogItem>(
        () => _i1061.DeleteCatalogItem(gh<_i128.CatalogRepository>()));
    gh.factory<_i962.LoadSystemOverview>(() => _i962.LoadSystemOverview(
          gh<_i654.AccountRepository>(),
          gh<_i1057.HotelChainRepository>(),
          gh<_i16.HotelRepository>(),
          gh<_i939.CustomerRepository>(),
          gh<_i83.EmployeeRepository>(),
        ));
    gh.lazySingleton<_i77.RoomRepository>(
        () => _i968.RoomRepositoryImpl(gh<_i679.RoomApi>()));
    gh.lazySingleton<_i695.TourBookingRepository>(
        () => _i856.TourBookingRepositoryImpl(gh<_i497.TourBookingApi>()));
    gh.lazySingleton<_i329.FavoritesCubit>(() => _i329.FavoritesCubit(
          gh<_i412.FavoriteStore>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.lazySingleton<_i922.PendingOwnersCubit>(
        () => _i922.PendingOwnersCubit(gh<_i387.CountPendingOwners>()));
    gh.factory<_i358.GetBranchServices>(
        () => _i358.GetBranchServices(gh<_i324.HotelServiceRepository>()));
    gh.factory<_i358.SaveService>(
        () => _i358.SaveService(gh<_i324.HotelServiceRepository>()));
    gh.factory<_i358.DeleteService>(
        () => _i358.DeleteService(gh<_i324.HotelServiceRepository>()));
    gh.factory<_i275.GetAccountsPage>(
        () => _i275.GetAccountsPage(gh<_i654.AccountRepository>()));
    gh.factory<_i275.GetAccount>(
        () => _i275.GetAccount(gh<_i654.AccountRepository>()));
    gh.factory<_i275.SetAccountActive>(
        () => _i275.SetAccountActive(gh<_i654.AccountRepository>()));
    gh.factory<_i728.BranchCubit>(
        () => _i728.BranchCubit(gh<_i672.GetHotelDetail>()));
    gh.factory<_i1019.HotelDetailCubit>(
        () => _i1019.HotelDetailCubit(gh<_i672.GetHotelDetail>()));
    gh.lazySingleton<_i129.NotificationRepository>(
        () => _i247.NotificationRepositoryImpl(gh<_i367.NotificationApi>()));
    gh.factory<_i109.LoadBranchDashboard>(() => _i109.LoadBranchDashboard(
          gh<_i12.ReportRepository>(),
          gh<_i299.BookingRepository>(),
        ));
    gh.factory<_i109.LoadRevenueReport>(
        () => _i109.LoadRevenueReport(gh<_i12.ReportRepository>()));
    gh.factory<_i109.LoadOccupancyReport>(
        () => _i109.LoadOccupancyReport(gh<_i12.ReportRepository>()));
    gh.factory<_i109.LoadBreakdownReport>(
        () => _i109.LoadBreakdownReport(gh<_i12.ReportRepository>()));
    gh.factory<_i109.LoadPeopleReport>(
        () => _i109.LoadPeopleReport(gh<_i12.ReportRepository>()));
    gh.factory<_i109.ExportReport>(
        () => _i109.ExportReport(gh<_i12.ReportRepository>()));
    gh.factory<_i109.LoadBranchComparison>(
        () => _i109.LoadBranchComparison(gh<_i12.ReportRepository>()));
    gh.factory<_i187.ExploreCubit>(() => _i187.ExploreCubit(
          gh<_i672.GetHotelsPage>(),
          gh<_i672.GetHotelsByCategory>(),
        ));
    gh.factory<_i854.CreateVnPayLink>(
        () => _i854.CreateVnPayLink(gh<_i545.PaymentRepository>()));
    gh.factory<_i854.ConfirmVnPayReturn>(
        () => _i854.ConfirmVnPayReturn(gh<_i545.PaymentRepository>()));
    gh.factory<_i1018.CatalogCubit>(
        () => _i1018.CatalogCubit(gh<_i1061.GetCatalog>()));
    gh.factory<_i782.GetChainManagers>(() => _i782.GetChainManagers(
          gh<_i654.AccountRepository>(),
          gh<_i232.ManagerRegistry>(),
        ));
    gh.factory<_i782.CreateManagerAccount>(() => _i782.CreateManagerAccount(
          gh<_i654.AccountRepository>(),
          gh<_i232.ManagerRegistry>(),
        ));
    gh.factory<_i320.GetBranchEmployees>(
        () => _i320.GetBranchEmployees(gh<_i83.EmployeeRepository>()));
    gh.factory<_i320.SaveEmployee>(
        () => _i320.SaveEmployee(gh<_i83.EmployeeRepository>()));
    gh.factory<_i320.DeleteEmployee>(
        () => _i320.DeleteEmployee(gh<_i83.EmployeeRepository>()));
    gh.factory<_i320.GetEmployeesPage>(
        () => _i320.GetEmployeesPage(gh<_i83.EmployeeRepository>()));
    gh.factory<_i750.OwnerRegistrationCubit>(
        () => _i750.OwnerRegistrationCubit(gh<_i387.GetOwnerRegistration>()));
    gh.factory<_i209.OpenConversation>(
        () => _i209.OpenConversation(gh<_i702.ChatRepository>()));
    gh.factory<_i209.GetConversations>(
        () => _i209.GetConversations(gh<_i702.ChatRepository>()));
    gh.factory<_i209.GetConversation>(
        () => _i209.GetConversation(gh<_i702.ChatRepository>()));
    gh.factory<_i209.GetChatMessages>(
        () => _i209.GetChatMessages(gh<_i702.ChatRepository>()));
    gh.factory<_i209.SendChatMessage>(
        () => _i209.SendChatMessage(gh<_i702.ChatRepository>()));
    gh.factory<_i209.MarkConversationRead>(
        () => _i209.MarkConversationRead(gh<_i702.ChatRepository>()));
    gh.factory<_i209.GetChatUnreadCount>(
        () => _i209.GetChatUnreadCount(gh<_i702.ChatRepository>()));
    gh.factory<_i836.LoginCubit>(() => _i836.LoginCubit(
          gh<_i856.Login>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.factory<_i782.LoadChainOverview>(() => _i782.LoadChainOverview(
          gh<_i1057.HotelChainRepository>(),
          gh<_i12.ReportRepository>(),
        ));
    gh.factory<_i57.GetCustomer>(
        () => _i57.GetCustomer(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.CreateCustomerProfile>(
        () => _i57.CreateCustomerProfile(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.UpdateCustomer>(
        () => _i57.UpdateCustomer(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.LinkWalkInProfile>(
        () => _i57.LinkWalkInProfile(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.FindCustomersByPhone>(
        () => _i57.FindCustomersByPhone(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.CreateWalkInCustomer>(
        () => _i57.CreateWalkInCustomer(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.GetBranchCustomers>(
        () => _i57.GetBranchCustomers(gh<_i939.CustomerRepository>()));
    gh.factory<_i57.GetCustomersPage>(
        () => _i57.GetCustomersPage(gh<_i939.CustomerRepository>()));
    gh.factory<_i1.ChainOverviewCubit>(
        () => _i1.ChainOverviewCubit(gh<_i782.LoadChainOverview>()));
    gh.factory<_i489.EmployeesPageCubit>(
        () => _i489.EmployeesPageCubit(gh<_i320.GetEmployeesPage>()));
    gh.factory<_i643.GetBranchDishes>(
        () => _i643.GetBranchDishes(gh<_i941.DishRepository>()));
    gh.factory<_i643.SaveDish>(
        () => _i643.SaveDish(gh<_i941.DishRepository>()));
    gh.factory<_i643.SetDishAvailable>(
        () => _i643.SetDishAvailable(gh<_i941.DishRepository>()));
    gh.factory<_i643.DeleteDish>(
        () => _i643.DeleteDish(gh<_i941.DishRepository>()));
    gh.factory<_i1048.SystemOverviewCubit>(
        () => _i1048.SystemOverviewCubit(gh<_i962.LoadSystemOverview>()));
    gh.factory<_i987.GetTourBookings>(
        () => _i987.GetTourBookings(gh<_i695.TourBookingRepository>()));
    gh.factory<_i987.GetTourBooking>(
        () => _i987.GetTourBooking(gh<_i695.TourBookingRepository>()));
    gh.factory<_i987.ChangeTourBookingStatus>(
        () => _i987.ChangeTourBookingStatus(gh<_i695.TourBookingRepository>()));
    gh.factory<_i987.CancelTourBooking>(
        () => _i987.CancelTourBooking(gh<_i695.TourBookingRepository>()));
    gh.factory<_i643.GetBranchRooms>(
        () => _i643.GetBranchRooms(gh<_i77.RoomRepository>()));
    gh.factory<_i643.GetRoomDetail>(
        () => _i643.GetRoomDetail(gh<_i77.RoomRepository>()));
    gh.factory<_i643.GetRoomsForDates>(
        () => _i643.GetRoomsForDates(gh<_i77.RoomRepository>()));
    gh.factory<_i643.SaveRoom>(() => _i643.SaveRoom(gh<_i77.RoomRepository>()));
    gh.factory<_i643.SetRoomStatus>(
        () => _i643.SetRoomStatus(gh<_i77.RoomRepository>()));
    gh.factory<_i643.DeleteRoom>(
        () => _i643.DeleteRoom(gh<_i77.RoomRepository>()));
    gh.factory<_i643.UploadRoomImages>(
        () => _i643.UploadRoomImages(gh<_i77.RoomRepository>()));
    gh.factory<_i856.ResolveStaffBranch>(() => _i856.ResolveStaffBranch(
          gh<_i16.HotelRepository>(),
          gh<_i83.EmployeeRepository>(),
        ));
    gh.factory<_i489.CustomersPageCubit>(
        () => _i489.CustomersPageCubit(gh<_i57.GetCustomersPage>()));
    gh.factory<_i750.CreateBooking>(
        () => _i750.CreateBooking(gh<_i299.BookingRepository>()));
    gh.factory<_i750.UpdateBooking>(
        () => _i750.UpdateBooking(gh<_i299.BookingRepository>()));
    gh.factory<_i750.GetBooking>(
        () => _i750.GetBooking(gh<_i299.BookingRepository>()));
    gh.factory<_i750.GetCustomerBookings>(
        () => _i750.GetCustomerBookings(gh<_i299.BookingRepository>()));
    gh.factory<_i750.GetBranchBookings>(
        () => _i750.GetBranchBookings(gh<_i299.BookingRepository>()));
    gh.factory<_i750.ChangeBookingStatus>(
        () => _i750.ChangeBookingStatus(gh<_i299.BookingRepository>()));
    gh.factory<_i750.ChangePaymentMethod>(
        () => _i750.ChangePaymentMethod(gh<_i299.BookingRepository>()));
    gh.factory<_i750.DeleteBooking>(
        () => _i750.DeleteBooking(gh<_i299.BookingRepository>()));
    gh.factory<_i534.DeskCubit>(
        () => _i534.DeskCubit(gh<_i750.GetBranchBookings>()));
    gh.factory<_i823.CustomerBookingsCubit>(
        () => _i823.CustomerBookingsCubit(gh<_i750.GetBranchBookings>()));
    gh.factory<_i769.SearchWithAi>(
        () => _i769.SearchWithAi(gh<_i444.AiRepository>()));
    gh.factory<_i769.SuggestChatReply>(
        () => _i769.SuggestChatReply(gh<_i444.AiRepository>()));
    gh.factory<_i769.GetAiBranchSettings>(
        () => _i769.GetAiBranchSettings(gh<_i444.AiRepository>()));
    gh.factory<_i769.SetAiAutoReply>(
        () => _i769.SetAiAutoReply(gh<_i444.AiRepository>()));
    gh.lazySingleton<_i769.AiAvailability>(
        () => _i769.AiAvailability(gh<_i444.AiRepository>()));
    gh.factory<_i134.SavePayroll>(
        () => _i134.SavePayroll(gh<_i625.PayrollRepository>()));
    gh.factory<_i1026.OwnerRegisterCubit>(() => _i1026.OwnerRegisterCubit(
          gh<_i387.RegisterOwner>(),
          gh<_i856.Login>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.factory<_i1003.DishesCubit>(
        () => _i1003.DishesCubit(gh<_i643.GetBranchDishes>()));
    gh.factory<_i508.RoomsManageCubit>(
        () => _i508.RoomsManageCubit(gh<_i643.GetBranchRooms>()));
    gh.factory<_i836.RegisterCubit>(() => _i836.RegisterCubit(
          gh<_i856.RegisterCustomer>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.factory<_i398.GetNotificationsPage>(
        () => _i398.GetNotificationsPage(gh<_i129.NotificationRepository>()));
    gh.factory<_i398.GetUnreadNotificationCount>(() =>
        _i398.GetUnreadNotificationCount(gh<_i129.NotificationRepository>()));
    gh.factory<_i398.MarkNotificationRead>(
        () => _i398.MarkNotificationRead(gh<_i129.NotificationRepository>()));
    gh.factory<_i398.MarkAllNotificationsRead>(() =>
        _i398.MarkAllNotificationsRead(gh<_i129.NotificationRepository>()));
    gh.factory<_i398.RegisterPushDevice>(
        () => _i398.RegisterPushDevice(gh<_i129.NotificationRepository>()));
    gh.factory<_i398.UnregisterPushDevice>(
        () => _i398.UnregisterPushDevice(gh<_i129.NotificationRepository>()));
    gh.factory<_i922.OwnerRegistrationsCubit>(
        () => _i922.OwnerRegistrationsCubit(gh<_i387.GetOwnerRegistrations>()));
    gh.factory<_i782.CreateHotelChain>(
        () => _i782.CreateHotelChain(gh<_i1057.HotelChainRepository>()));
    gh.factory<_i782.UpdateHotelChain>(
        () => _i782.UpdateHotelChain(gh<_i1057.HotelChainRepository>()));
    gh.factory<_i782.DeleteHotelChain>(
        () => _i782.DeleteHotelChain(gh<_i1057.HotelChainRepository>()));
    gh.factory<_i782.GetHotelChainDetail>(
        () => _i782.GetHotelChainDetail(gh<_i1057.HotelChainRepository>()));
    gh.factory<_i782.GetHotelChainsPage>(
        () => _i782.GetHotelChainsPage(gh<_i1057.HotelChainRepository>()));
    gh.factory<_i999.BranchCustomersCubit>(
        () => _i999.BranchCustomersCubit(gh<_i57.GetBranchCustomers>()));
    gh.factory<_i785.RoomAdminCubit>(
        () => _i785.RoomAdminCubit(gh<_i643.GetRoomDetail>()));
    gh.lazySingleton<_i966.PushService>(() => _i966.PushService(
          gh<_i398.RegisterPushDevice>(),
          gh<_i398.UnregisterPushDevice>(),
        ));
    gh.factory<_i102.PayrollCubit>(() => _i102.PayrollCubit(
          gh<_i320.GetBranchEmployees>(),
          gh<_i134.SavePayroll>(),
          gh<_i381.PayrollSessionStore>(),
        ));
    gh.factory<_i79.DashboardCubit>(
        () => _i79.DashboardCubit(gh<_i109.LoadBranchDashboard>()));
    gh.factory<_i1049.ServicesCubit>(
        () => _i1049.ServicesCubit(gh<_i358.GetBranchServices>()));
    gh.factory<_i388.ProfileSetupCubit>(() => _i388.ProfileSetupCubit(
          gh<_i57.LinkWalkInProfile>(),
          gh<_i57.CreateCustomerProfile>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.factory<_i811.MyBookingsCubit>(() => _i811.MyBookingsCubit(
          gh<_i750.GetCustomerBookings>(),
          gh<_i642.SessionCubit>(),
        ));
    gh.factory<_i25.NotificationsCubit>(() => _i25.NotificationsCubit(
          gh<_i398.GetNotificationsPage>(),
          gh<_i398.MarkNotificationRead>(),
          gh<_i398.MarkAllNotificationsRead>(),
        ));
    gh.lazySingleton<_i493.ChatUnreadCubit>(
        () => _i493.ChatUnreadCubit(gh<_i209.GetChatUnreadCount>()));
    gh.factory<_i978.ReportsCubit>(() => _i978.ReportsCubit(
          gh<_i109.LoadRevenueReport>(),
          gh<_i109.LoadOccupancyReport>(),
          gh<_i109.LoadBreakdownReport>(),
          gh<_i109.LoadPeopleReport>(),
          gh<_i109.ExportReport>(),
          gh<_i109.LoadBranchComparison>(),
          gh<_i782.GetHotelChainDetail>(),
        ));
    gh.factory<_i489.ChainsPageCubit>(
        () => _i489.ChainsPageCubit(gh<_i782.GetHotelChainsPage>()));
    gh.factory<_i625.BookingCreateCubit>(() => _i625.BookingCreateCubit(
          gh<_i672.GetHotelDetail>(),
          gh<_i750.CreateBooking>(),
        ));
    gh.factory<_i770.AccountsCubit>(
        () => _i770.AccountsCubit(gh<_i275.GetAccountsPage>()));
    gh.factory<_i420.TourBookingsCubit>(
        () => _i420.TourBookingsCubit(gh<_i987.GetTourBookings>()));
    gh.factory<_i209.WalkInGuestCubit>(() => _i209.WalkInGuestCubit(
          gh<_i57.FindCustomersByPhone>(),
          gh<_i57.CreateWalkInCustomer>(),
        ));
    gh.factory<_i747.TourBookingDetailCubit>(() => _i747.TourBookingDetailCubit(
          gh<_i987.GetTourBooking>(),
          gh<_i987.ChangeTourBookingStatus>(),
          gh<_i987.CancelTourBooking>(),
        ));
    gh.lazySingleton<_i534.NotificationBadgeCubit>(
        () => _i534.NotificationBadgeCubit(
              gh<_i398.GetUnreadNotificationCount>(),
              gh<_i398.GetNotificationsPage>(),
            ));
    gh.lazySingleton<_i493.ChatHub>(() => _i493.ChatHub(
          gh<_i485.ChatSocket>(),
          gh<_i493.ChatUnreadCubit>(),
        ));
    gh.factory<_i41.EmployeesCubit>(
        () => _i41.EmployeesCubit(gh<_i320.GetBranchEmployees>()));
    gh.factory<_i932.ConversationsCubit>(() => _i932.ConversationsCubit(
          gh<_i209.GetConversations>(),
          gh<_i485.ChatSocket>(),
        ));
    gh.factory<_i955.RoomDetailCubit>(() => _i955.RoomDetailCubit(
          gh<_i643.GetRoomDetail>(),
          gh<_i643.GetRoomsForDates>(),
        ));
    gh.factory<_i1.ManagersCubit>(() => _i1.ManagersCubit(
          gh<_i782.GetHotelChainDetail>(),
          gh<_i782.GetChainManagers>(),
        ));
    gh.factory<_i1027.BookingEditCubit>(() => _i1027.BookingEditCubit(
          gh<_i750.GetBooking>(),
          gh<_i672.GetHotelDetail>(),
          gh<_i750.UpdateBooking>(),
        ));
    gh.factory<_i287.BookingDetailCubit>(() => _i287.BookingDetailCubit(
          gh<_i750.GetBooking>(),
          gh<_i750.ChangeBookingStatus>(),
          gh<_i750.ChangePaymentMethod>(),
          gh<_i750.DeleteBooking>(),
        ));
    gh.factory<_i1050.AiSearchCubit>(
        () => _i1050.AiSearchCubit(gh<_i769.SearchWithAi>()));
    gh.factory<_i1.ChainCubit>(
        () => _i1.ChainCubit(gh<_i782.GetHotelChainDetail>()));
    gh.factory<_i158.ChatCubit>(() => _i158.ChatCubit(
          gh<_i209.GetConversation>(),
          gh<_i209.GetChatMessages>(),
          gh<_i209.SendChatMessage>(),
          gh<_i209.MarkConversationRead>(),
          gh<_i485.ChatSocket>(),
          gh<_i493.ChatHub>(),
        ));
    return this;
  }
}

class _$AppModule extends _i732.AppModule {}

class _$AccountApiModule extends _i458.AccountApiModule {}

class _$AmenityApiModule extends _i619.AmenityApiModule {}

class _$AuthApiModule extends _i165.AuthApiModule {}

class _$BookingApiModule extends _i691.BookingApiModule {}

class _$CatalogApiModule extends _i477.CatalogApiModule {}

class _$CustomerApiModule extends _i294.CustomerApiModule {}

class _$EmployeeApiModule extends _i618.EmployeeApiModule {}

class _$FeedbackApiModule extends _i621.FeedbackApiModule {}

class _$HotelApiModule extends _i1009.HotelApiModule {}

class _$HotelChainApiModule extends _i502.HotelChainApiModule {}

class _$NotificationApiModule extends _i367.NotificationApiModule {}

class _$PartnerApiModule extends _i635.PartnerApiModule {}

class _$PaymentApiModule extends _i219.PaymentApiModule {}

class _$PayrollApiModule extends _i981.PayrollApiModule {}

class _$RoomApiModule extends _i679.RoomApiModule {}

class _$ServiceApiModule extends _i17.ServiceApiModule {}

class _$DishApiModule extends _i725.DishApiModule {}

class _$ChatApiModule extends _i204.ChatApiModule {}

class _$AiApiModule extends _i431.AiApiModule {}

class _$TourApiModule extends _i424.TourApiModule {}

class _$TourBookingApiModule extends _i497.TourBookingApiModule {}
