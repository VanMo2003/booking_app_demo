import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/bloc/paged_cubit.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/network/paged.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/partner_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../notification/presentation/notification_bell.dart';
import '../../notification/services/notification_events.dart';
import '../../partner/domain/usecases/partner_usecases.dart';

/// Số hồ sơ chủ khách sạn chờ duyệt — huy hiệu tab Xét duyệt, thẻ ở Tổng quan.
@lazySingleton
class PendingOwnersCubit extends Cubit<int> {
  PendingOwnersCubit(this._count) : super(0);

  final CountPendingOwners _count;

  Future<void> refresh() async {
    try {
      final count = await _count();
      if (!isClosed) emit(count);
    } catch (_) {
      // Giữ số cũ khi mất mạng.
    }
  }
}

@injectable
class OwnerRegistrationsCubit extends PagedCubit<HotelChain> {
  OwnerRegistrationsCubit(this._getPage);

  final GetOwnerRegistrations _getPage;
  ApprovalStatus _status = ApprovalStatus.pending;

  ApprovalStatus get status => _status;

  Future<void> select(ApprovalStatus status) {
    if (status == _status) return Future.value();
    _status = status;
    emit(const PagedState<HotelChain>());
    return load();
  }

  @override
  Future<Paged<HotelChain>> fetch({required int page, required int size}) =>
      _getPage(status: _status, page: page, size: size);
}

/// Tab Xét duyệt của quản trị viên: hàng chờ hồ sơ chủ khách sạn và hồ sơ đã xử lý.
@RoutePage()
class OwnerApprovalsScreen extends StatelessWidget {
  const OwnerApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OwnerRegistrationsCubit>()..load(),
      child: const _OwnerApprovalsView(),
    );
  }
}

class _OwnerApprovalsView extends StatefulWidget {
  const _OwnerApprovalsView();

  @override
  State<_OwnerApprovalsView> createState() => _OwnerApprovalsViewState();
}

class _OwnerApprovalsViewState extends State<_OwnerApprovalsView> {
  StreamSubscription<void>? _events;

  @override
  void initState() {
    super.initState();
    _events = getIt<NotificationEvents>().onChanged.listen((_) => _reload());
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final pending = context.read<PendingOwnersCubit>();
    await context.read<OwnerRegistrationsCubit>().load();
    await pending.refresh();
  }

  Future<void> _open(HotelChain chain) async {
    final changed = await context.rootRouter.push<bool>(
      OwnerRegistrationDetailRoute(chainId: chain.id, initial: chain),
    );
    if (changed == true && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerRegistrationsCubit, PagedState<HotelChain>>(
      builder: (context, state) {
        final cubit = context.read<OwnerRegistrationsCubit>();
        final pending = cubit.status == ApprovalStatus.pending;
        return AppPage(
          title: PartnerStrings.approvalsTitle,
          subtitle: state.status == ViewStatus.success
              ? '${cubit.status.label} · ${AppStrings.itemsCount(state.total)}'
              : null,
          actions: [
            const NotificationBell(),
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          body: Column(
            children: [
              const Gap(AppSpacing.xs),
              ChoiceChipBar<ApprovalStatus>(
                options: ApprovalStatus.values,
                selected: cubit.status,
                labelOf: (status) => status.label,
                onSelected: cubit.select,
              ),
              const Gap(AppSpacing.xs),
              Expanded(
                child: PagedListView<HotelChain>(
                  state: state,
                  onRefresh: _reload,
                  onLoadMore: cubit.loadMore,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                  empty: AppEmptyView(
                    // Hết hồ sơ chờ duyệt là việc đã xong, không phải danh sách cần thêm.
                    image: pending
                        ? const AppIllustration(type: AppIllustrationType.approved)
                        : null,
                    icon: pending ? Icons.task_alt_rounded : Icons.inventory_2_outlined,
                    title: pending
                        ? PartnerStrings.approvalsEmptyPending
                        : PartnerStrings.approvalsEmpty,
                    message: pending ? PartnerStrings.approvalsEmptyPendingHint : null,
                  ),
                  itemBuilder: (context, chain) => _RegistrationCard(
                    chain: chain,
                    onTap: () => _open(chain),
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

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.chain, required this.onTap});

  final HotelChain chain;
  final VoidCallback onTap;

  String? get _time {
    if (chain.approvalStatus == ApprovalStatus.pending) {
      return chain.submittedAt == null
          ? null
          : PartnerStrings.submittedOn(Fmt.dateTime(chain.submittedAt));
    }
    final decidedAt = chain.reviewedAt ?? chain.submittedAt;
    return decidedAt == null ? null : PartnerStrings.reviewedOn(Fmt.dateTime(decidedAt));
  }

  @override
  Widget build(BuildContext context) {
    final owner = [
      chain.ownerName,
      if (chain.ownerUsername != null) '@${chain.ownerUsername}',
    ].where((part) => part.isNotEmpty).join(' · ');
    final resubmitted =
        chain.approvalStatus == ApprovalStatus.pending && chain.rejectionReason != null;
    final time = _time;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: chain.name, size: 44, tone: chain.approvalStatus.tone),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chain.name,
                        style: AppTextStyles.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    StatusBadge.approval(chain.approvalStatus, dense: true),
                  ],
                ),
                if (owner.isNotEmpty)
                  Text(
                    owner,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (chain.address.isNotEmpty) ...[
                  const Gap(4),
                  IconText(icon: Icons.location_on_outlined, text: chain.address),
                ],
                if (time != null || resubmitted) ...[
                  const Gap(6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (resubmitted)
                        const SoftTag(
                          label: PartnerStrings.resubmittedTag,
                          tone: StatusTone.info,
                          icon: Icons.replay_rounded,
                        ),
                      if (time != null) Text(time, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
        ],
      ),
    );
  }
}
