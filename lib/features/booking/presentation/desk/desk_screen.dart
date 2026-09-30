import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../chat/presentation/chat_entry.dart';
import '../../../shell/presentation/workspace_scope.dart';
import '../../domain/entities/booking.dart';
import '../widgets/booking_card.dart';
import 'desk_cubit.dart';

/// Tab Quầy lễ tân.
@RoutePage()
class DeskScreen extends StatelessWidget {
  const DeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelId = WorkspaceScope.of(context).hotelId;
    return BlocProvider(
      key: ValueKey(hotelId),
      create: (_) => getIt<DeskCubit>()..start(hotelId),
      child: _DeskView(hotelId: hotelId),
    );
  }
}

class _DeskView extends StatefulWidget {
  const _DeskView({required this.hotelId});

  final int hotelId;

  @override
  State<_DeskView> createState() => _DeskViewState();
}

class _DeskViewState extends State<_DeskView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static String _label(DeskFilter filter) => switch (filter) {
        DeskFilter.arrivals => BookingStrings.filterArrivals,
        DeskFilter.departures => BookingStrings.filterDepartures,
        DeskFilter.inHouse => BookingStrings.filterInHouse,
        DeskFilter.pending => BookingStrings.filterPending,
        DeskFilter.all => BookingStrings.filterAll,
      };

  Future<void> _open(Booking booking) async {
    await context.rootRouter.push(BookingDetailRoute(bookingId: booking.id));
    if (mounted) await context.read<DeskCubit>().load();
  }

  Future<void> _walkIn() async {
    await context.rootRouter.push(WalkInBookingRoute(hotelId: widget.hotelId));
    if (mounted) await context.read<DeskCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final branchName = context.branchName;
    final today = DateOnly.today();
    return BlocBuilder<DeskCubit, DeskState>(
      builder: (context, state) {
        final cubit = context.read<DeskCubit>();
        final visible = state.visible;
        // Danh sách trống thì nút tạo đơn nằm ngay trong trạng thái rỗng.
        final showFab = !(state.bookings.hasData && visible.isEmpty);
        return AppPage(
          title: BookingStrings.deskTitle,
          subtitle: [
            if (branchName != null) branchName,
            '${Fmt.weekdayLong(today)}, ${Fmt.date(today)}',
          ].join(' · '),
          actions: [
            if (WorkspaceScope.of(context).role != Role.admin)
              ChatInboxButton(hotelId: widget.hotelId, branchName: branchName),
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          floatingActionButton: showFab
              ? FloatingActionButton.extended(
                  onPressed: _walkIn,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(BookingStrings.walkInAction),
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: AppSearchField(
                  controller: _search,
                  hint: BookingStrings.deskSearchHint,
                  onChanged: cubit.setQuery,
                ),
              ),
              ChoiceChipBar<DeskFilter>(
                options: DeskFilter.values,
                selected: state.filter,
                labelOf: _label,
                countOf: state.bookings.hasData ? state.count : null,
                onSelected: cubit.setFilter,
              ),
              const Gap(AppSpacing.xs),
              if (state.bookings.isLoading && state.bookings.hasData)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: LoadStateView<List<Booking>>(
                  state: state.bookings,
                  onRetry: cubit.load,
                  builder: (context, _) => RefreshIndicator(
                    onRefresh: cubit.load,
                    child: visible.isEmpty
                        ? ListView(
                            children: [
                              AppEmptyView(
                                icon: Icons.event_available_outlined,
                                title: BookingStrings.deskEmpty,
                                message: BookingStrings.deskEmptyHint,
                                addLabel: BookingStrings.walkInAction,
                                onAdd: _walkIn,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              AppSpacing.bottomBarClearance,
                            ),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                            itemBuilder: (context, index) => BookingCard(
                              booking: visible[index],
                              view: BookingCardView.desk,
                              onTap: () => _open(visible[index]),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
