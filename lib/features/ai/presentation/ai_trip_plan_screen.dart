import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../tour/domain/entities/tour.dart';
import '../../tour/presentation/tour_detail_screen.dart';
import '../../voucher/presentation/voucher_widgets.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

@injectable
class AiTripPlanCubit extends LoadCubit<AiTripPlan> {
  AiTripPlanCubit(this._plan);

  final PlanTripWithAi _plan;
  String _query = '';

  Future<void> plan(String query) {
    _query = query.trim();
    if (_query.isEmpty) return Future.value();
    return load();
  }

  @override
  Future<void> load() => guard(() => _plan(_query));
}

/// Lên kế hoạch cả chuyến đi từ một câu mô tả: AI xếp lịch trình từng ngày, nhưng khách sạn, phòng, tour
/// và mọi khoản tiền đều do máy chủ lấy từ dữ liệu thật — xem xong là đặt được luôn.
@RoutePage()
class AiTripPlanScreen extends StatelessWidget {
  const AiTripPlanScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AiTripPlanCubit>();
        if (initialQuery != null) cubit.plan(initialQuery!);
        return cubit;
      },
      child: _AiTripPlanView(initialQuery: initialQuery),
    );
  }
}

class _AiTripPlanView extends StatefulWidget {
  const _AiTripPlanView({this.initialQuery});

  final String? initialQuery;

  @override
  State<_AiTripPlanView> createState() => _AiTripPlanViewState();
}

class _AiTripPlanViewState extends State<_AiTripPlanView> {
  late final _query = TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? text]) {
    if (text != null) _query.text = text;
    FocusScope.of(context).unfocus();
    context.read<AiTripPlanCubit>().plan(_query.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AiStrings.tripTitle,
      body: BlocBuilder<AiTripPlanCubit, LoadState<AiTripPlan>>(
        builder: (context, state) {
          final busy = state.isLoading;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(AiStrings.tripIntro, style: AppTextStyles.bodySmall),
              const Gap(AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                        ),
                        const Gap(AppSpacing.xs),
                        Expanded(
                          child: TextField(
                            controller: _query,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 300,
                            textInputAction: TextInputAction.newline,
                            style: AppTextStyles.body,
                            decoration: const InputDecoration(
                              hintText: AiStrings.tripHint,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              counterText: '',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    AppButton(
                      label: AiStrings.tripAction,
                      icon: Icons.auto_awesome_rounded,
                      loading: busy,
                      onPressed: busy ? null : _submit,
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              ...switch (state.status) {
                ViewStatus.initial => [_TripExamples(onPick: _submit)],
                ViewStatus.loading when !state.hasData => const [AppLoadingView()],
                ViewStatus.failure => [
                    AppFailureView.fromState(state, onRetry: () => _submit(), compact: true),
                    const Gap(AppSpacing.md),
                    _TripExamples(onPick: _submit),
                  ],
                _ => [_TripPlanView(plan: state.data!)],
              },
            ],
          );
        },
      ),
    );
  }
}

class _TripExamples extends StatelessWidget {
  const _TripExamples({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.examplesTitle),
        for (final example in AiStrings.tripExamples) ...[
          AppCard(
            onTap: () => onPick(example),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: IconText(
              icon: Icons.north_west_rounded,
              iconColor: AppColors.primary,
              text: example,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const Gap(AppSpacing.xs),
        ],
      ],
    );
  }
}

/// Điều AI hiểu về chuyến đi, viết thành các thẻ nhỏ.
abstract final class AiTripChips {
  static List<String> of(AiTripPlan plan) => [
        if (plan.destination != null) plan.destination!,
        AiStrings.tripNights(plan.nights),
        if (plan.startDate != null) Fmt.date(plan.startDate),
        AiStrings.tourGuests(plan.adults, plan.children),
        for (final theme in plan.themes) theme.label,
        if (plan.budget != null) AiStrings.tripBudget(Fmt.money(plan.budget)),
      ];
}

class _TripPlanView extends StatelessWidget {
  const _TripPlanView({required this.plan});

  final AiTripPlan plan;

  Tour? _tour(int? id) {
    if (id == null) return null;
    for (final tour in plan.tours) {
      if (tour.id == id) return tour;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stay = plan.stay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GroupLabel(AiStrings.understood),
        if (plan.summary != null) ...[
          Text(plan.summary!, style: AppTextStyles.bodyMedium),
          const Gap(AppSpacing.xs),
        ],
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final tag in AiTripChips.of(plan)) SoftTag(label: tag, tone: StatusTone.brand)],
        ),
        for (final note in plan.notes) ...[
          const Gap(AppSpacing.xs),
          NoticeBanner(text: note, tone: StatusTone.warning),
        ],
        if (stay == null)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: AppEmptyView(
              icon: Icons.map_outlined,
              title: AiStrings.tripNothing,
              message: AiStrings.tripNothingHint,
              compact: true,
            ),
          )
        else ...[
          const Gap(AppSpacing.lg),
          const SectionHeader(title: AiStrings.tripStay),
          const Gap(AppSpacing.xs),
          _StayCard(stay: stay),
          if (plan.days.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: AiStrings.tripSchedule),
            const Gap(AppSpacing.sm),
            for (final day in plan.days) ...[
              _DayCard(day: day, tourOf: _tour),
              const Gap(AppSpacing.sm),
            ],
          ],
          const Gap(AppSpacing.md),
          const SectionHeader(title: AiStrings.tripCostTitle),
          const Gap(AppSpacing.xs),
          _CostCard(plan: plan),
          if (plan.tours.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            const SectionHeader(title: AiStrings.tripToursTitle),
            const Gap(AppSpacing.xs),
            for (final tour in plan.tours) ...[
              TourCardLink(tour: tour, hotelName: tour.hotelName),
              const Gap(AppSpacing.xs),
            ],
          ],
        ],
      ],
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.stay});

  final TripStay stay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(path: stay.image, width: 80, height: 80, borderRadius: AppRadius.smAll),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stay.hotelName, style: AppTextStyles.bodyStrong, maxLines: 2),
                    const Gap(2),
                    Text(stay.address, style: AppTextStyles.caption, maxLines: 2),
                    const Gap(4),
                    Text(AiStrings.tripRoom(stay.roomNumber, stay.roomType), style: AppTextStyles.bodySmall),
                    Text(
                      AiStrings.tripPerNight(Fmt.money(stay.pricePerNight)),
                      style: AppTextStyles.bodyStrong.colored(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          IconText(
            icon: Icons.event_rounded,
            text: '${Fmt.date(stay.checkin)} – ${Fmt.date(stay.checkout)}',
            style: AppTextStyles.bodySmall,
          ),
          const Gap(AppSpacing.xs),
          AppButton.tonal(
            label: AiStrings.tripBookStay,
            icon: Icons.hotel_rounded,
            onPressed: () => context.router.push(
              HotelDetailRoute(hotelId: stay.hotelId, checkin: stay.checkin, checkout: stay.checkout),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.tourOf});

  final TripDay day;
  final Tour? Function(int?) tourOf;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftTag(label: '${AiStrings.tripDay} ${day.index}', tone: StatusTone.brand),
              const Gap(AppSpacing.xs),
              Expanded(child: Text(Fmt.weekdayDate(day.date), style: AppTextStyles.caption)),
            ],
          ),
          if (day.title != null) ...[
            const Gap(4),
            Text(day.title!, style: AppTextStyles.bodyStrong),
          ],
          const Gap(AppSpacing.sm),
          for (var i = 0; i < day.steps.length; i++)
            _StepRow(
              step: day.steps[i],
              tour: tourOf(day.steps[i].tourId),
              last: i == day.steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.tour, required this.last});

  final TripStep step;
  final Tour? tour;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.time != null) Text(step.time!, style: AppTextStyles.caption.colored(AppColors.primary)),
        Row(
          children: [
            Expanded(child: Text(step.title, style: AppTextStyles.bodyStrong)),
            if (tour != null) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inkTertiary),
          ],
        ),
        if (step.detail != null) Text(step.detail!, style: AppTextStyles.bodySmall),
        if (tour != null)
          Text(
            AiStrings.fromPrice(Fmt.money(tour!.salePrice)).replaceAll('/đêm', ''),
            style: AppTextStyles.caption.colored(AppColors.primary),
          ),
      ],
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tour == null ? AppColors.surface : AppColors.primary,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                if (!last) Expanded(child: Container(width: 2, color: AppColors.primarySoft)),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.sm),
              child: tour == null
                  ? body
                  : InkWell(
                      onTap: () => context.router.push(TourDetailRoute(tour: tour, hotelName: tour!.hotelName)),
                      child: body,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.plan});

  final AiTripPlan plan;

  @override
  Widget build(BuildContext context) {
    final cost = plan.cost;
    final voucher = plan.voucher;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.hotel_rounded,
                label: AiStrings.tripCostRooms,
                value: Fmt.money(cost.rooms),
              ),
              InfoRow(
                icon: Icons.tour_rounded,
                label: AiStrings.tripCostTours,
                value: Fmt.money(cost.tours),
              ),
              if (cost.voucherDiscount != null)
                InfoRow(
                  icon: Icons.local_activity_rounded,
                  label: voucher == null ? AiStrings.tripCostVoucher : voucher.code,
                  value: '-${Fmt.money(cost.voucherDiscount)}',
                  valueStyle: AppTextStyles.bodyStrong.colored(AppColors.success),
                ),
              InfoRow(
                icon: Icons.payments_rounded,
                label: AiStrings.tripCostTotal,
                value: Fmt.money(cost.total),
                valueStyle: AppTextStyles.subtitle.colored(AppColors.primary),
              ),
              InfoRow(
                icon: Icons.person_rounded,
                label: AiStrings.tripCostPerPerson,
                value: Fmt.money(cost.perPerson),
              ),
              if (cost.leftOver != null)
                InfoRow(
                  icon: cost.overBudget ? Icons.warning_amber_rounded : Icons.savings_rounded,
                  label: cost.overBudget ? AiStrings.tripCostOver : AiStrings.tripCostLeft,
                  value: Fmt.money(cost.leftOver!.abs()),
                  valueStyle: AppTextStyles.bodyStrong
                      .colored(cost.overBudget ? AppColors.danger : AppColors.success),
                ),
            ],
          ),
        ),
        if (voucher != null) ...[
          const Gap(AppSpacing.xs),
          VoucherTicket(voucher: voucher),
        ],
        const Gap(AppSpacing.xs),
        Text(AiStrings.tripCostNote, style: AppTextStyles.caption),
      ],
    );
  }
}
