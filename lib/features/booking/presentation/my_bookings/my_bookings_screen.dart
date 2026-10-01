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
import '../../../../core/text/auth_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/tour_strings.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../notification/presentation/notification_bell.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../widgets/booking_card.dart';

@injectable
class MyBookingsCubit extends LoadCubit<List<Booking>> {
  MyBookingsCubit(this._getBookings, this._session);

  final GetCustomerBookings _getBookings;
  final SessionCubit _session;

  @override
  Future<void> load() async {
    final customerId = _session.session?.customer?.id;
    if (customerId == null) {
      emit(const LoadState(status: ViewStatus.success, data: []));
      return;
    }
    await guard(() => _getBookings(customerId));
  }
}

/// Tab "Đơn của tôi" — cần đăng nhập và hồ sơ khách hàng.
@RoutePage()
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        final session = sessionState.session;
        if (session == null) {
          return AppPage(
            title: BookingStrings.myBookingsTitle,
            automaticallyImplyLeading: false,
            body: LoginPromptView(
              title: AuthStrings.loginRequiredTitle,
              message: AuthStrings.loginRequiredBookings,
              icon: Icons.receipt_long_outlined,
              onLogin: () => context.rootRouter.push<bool>(LoginRoute(returnResult: true)),
              onRegister: () => context.rootRouter.push<bool>(RegisterRoute(returnResult: true)),
            ),
          );
        }
        if (session.role != Role.customer) {
          return const AppPage(
            title: BookingStrings.myBookingsTitle,
            automaticallyImplyLeading: false,
            body: AppEmptyView(title: AuthStrings.customerOnly),
          );
        }
        if (session.customer == null) {
          return AppPage(
            title: BookingStrings.myBookingsTitle,
            automaticallyImplyLeading: false,
            body: AppEmptyView(
              icon: Icons.badge_outlined,
              title: AuthStrings.setupTitle,
              message: AuthStrings.setupCreateSubtitle,
              action: AppButton(
                label: AuthStrings.setupTitle,
                onPressed: () => context.rootRouter.push<bool>(ProfileSetupRoute(returnResult: true)),
              ),
            ),
          );
        }
        return BlocProvider(
          key: ValueKey(session.customer!.id),
          create: (_) => getIt<MyBookingsCubit>()..load(),
          child: const _MyBookingsView(),
        );
      },
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

  static const _filters = <BookingStatus?>[
    null,
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.completed,
    BookingStatus.canceled,
  ];

  static bool _matches(Booking booking, BookingStatus? filter) {
    if (filter == null) return true;
    if (filter == BookingStatus.pending) {
      return booking.status == BookingStatus.pending || booking.status == BookingStatus.paying;
    }
    return booking.status == filter;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBookingsCubit, LoadState<List<Booking>>>(
      builder: (context, state) {
        final cubit = context.read<MyBookingsCubit>();
        final bookings = state.data ?? const <Booking>[];
        return DefaultTabController(
          length: _filters.length,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(BookingStrings.myBookingsTitle),
              actions: [
                TextButton.icon(
                  onPressed: () => context.rootRouter.push(TourBookingsRoute()),
                  icon: const Icon(Icons.tour_outlined, size: 20),
                  label: const Text(TourBookingStrings.entry),
                ),
                const NotificationBell(),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final filter in _filters)
                    Tab(
                      text:
                          '${filter?.label ?? AppStrings.all} (${bookings.where((b) => _matches(b, filter)).length})',
                    ),
                ],
              ),
            ),
            body: LoadStateView<List<Booking>>(
              state: state,
              onRetry: cubit.load,
              builder: (context, data) => TabBarView(
                children: [
                  for (final filter in _filters)
                    _BookingList(
                      bookings: data.where((b) => _matches(b, filter)).toList(),
                      onRefresh: cubit.load,
                      showExplore: filter == null,
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
    required this.onRefresh,
    required this.showExplore,
  });

  final List<Booking> bookings;
  final Future<void> Function() onRefresh;
  final bool showExplore;

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
                  icon: Icons.receipt_long_outlined,
                  title: showExplore ? BookingStrings.bookingsEmpty : BookingStrings.bookingsEmptyStatus,
                  message: showExplore ? BookingStrings.bookingsEmptyHint : null,
                  action: showExplore
                      ? AppButton.secondary(
                          label: BookingStrings.exploreNow,
                          icon: Icons.travel_explore_rounded,
                          size: AppButtonSize.medium,
                          onPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
                        )
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
                return BookingCard(
                  booking: booking,
                  onTap: () async {
                    await context.rootRouter.push(BookingDetailRoute(bookingId: booking.id));
                    await onRefresh();
                  },
                );
              },
            ),
    );
  }
}
