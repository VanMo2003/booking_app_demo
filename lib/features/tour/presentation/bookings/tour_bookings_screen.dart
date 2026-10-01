import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/tour_strings.dart';
import '../../domain/entities/tour_booking.dart';
import '../../domain/usecases/tour_booking_usecases.dart';
import '../widgets/tour_booking_card.dart';

@injectable
class TourBookingsCubit extends LoadCubit<List<TourBooking>> {
  TourBookingsCubit(this._getBookings);

  final GetTourBookings _getBookings;
  int? _hotelId;

  Future<void> start(int? hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getBookings(hotelId: _hotelId));
}

/// Đơn tour. Không truyền [hotelId]: đơn của khách đang đăng nhập ("Đơn tour của tôi");
/// có [hotelId]: đơn của cơ sở cho đội ngũ xác nhận, hoàn tất, huỷ.
@RoutePage()
class TourBookingsScreen extends StatelessWidget {
  const TourBookingsScreen({super.key, this.hotelId});

  final int? hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TourBookingsCubit>()..start(hotelId),
      child: _TourBookingsView(forGuest: hotelId == null),
    );
  }
}

class _TourBookingsView extends StatelessWidget {
  const _TourBookingsView({required this.forGuest});

  final bool forGuest;

  static const _filters = <TourBookingStatus?>[
    null,
    TourBookingStatus.pending,
    TourBookingStatus.confirmed,
    TourBookingStatus.completed,
    TourBookingStatus.canceled,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TourBookingsCubit, LoadState<List<TourBooking>>>(
      builder: (context, state) {
        final cubit = context.read<TourBookingsCubit>();
        final bookings = state.data ?? const <TourBooking>[];
        List<TourBooking> of(TourBookingStatus? filter) =>
            filter == null ? bookings : bookings.where((b) => b.status == filter).toList();
        return DefaultTabController(
          length: _filters.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(forGuest ? TourBookingStrings.myTitle : TourBookingStrings.branchTitle),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final filter in _filters) Tab(text: '${filter?.label ?? AppStrings.all} (${of(filter).length})'),
                ],
              ),
            ),
            body: LoadStateView<List<TourBooking>>(
              state: state,
              onRetry: cubit.load,
              builder: (context, _) => TabBarView(
                children: [
                  for (final filter in _filters)
                    _BookingList(
                      bookings: of(filter),
                      forGuest: forGuest,
                      allTab: filter == null,
                      onRefresh: cubit.load,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.forGuest,
    required this.allTab,
    required this.onRefresh,
  });

  final List<TourBooking> bookings;
  final bool forGuest;
  final bool allTab;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: bookings.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Gap(AppSpacing.xxl),
                AppEmptyView(
                  icon: Icons.tour_outlined,
                  title: allTab ? TourBookingStrings.empty : TourBookingStrings.emptyStatus,
                  message: allTab
                      ? (forGuest ? TourBookingStrings.emptyMineHint : TourBookingStrings.emptyBranchHint)
                      : null,
                ),
              ],
            )
          : ListView.separated(
              padding: AppSpacing.page,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return TourBookingCard(
                  booking: booking,
                  forGuest: forGuest,
                  onTap: () async {
                    await context.rootRouter.push(TourBookingDetailRoute(bookingId: booking.id));
                    await onRefresh();
                  },
                );
              },
            ),
    );
  }
}
