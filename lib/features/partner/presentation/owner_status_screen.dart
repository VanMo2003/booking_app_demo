import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/partner_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../notification/presentation/notification_bell.dart';
import '../../notification/services/notification_events.dart';
import '../domain/usecases/partner_usecases.dart';
import 'widgets/review_note.dart';

/// Chủ khách sạn đã đăng ký nhưng chưa được duyệt: xem trạng thái, sửa hồ sơ,
/// gửi lại khi bị từ chối. Tự kiểm tra lại mỗi 30 giây, khi quay lại app và khi
/// có thông báo mới; được duyệt thì chuyển thẳng vào khung chủ khách sạn.
@RoutePage()
class OwnerStatusScreen extends StatefulWidget {
  const OwnerStatusScreen({super.key});

  @override
  State<OwnerStatusScreen> createState() => _OwnerStatusScreenState();
}

class _OwnerStatusScreenState extends State<OwnerStatusScreen> {
  static const _interval = Duration(seconds: 30);

  late final AppLifecycleListener _lifecycle;
  StreamSubscription<void>? _events;
  Timer? _timer;
  bool _checking = false;
  DateTime? _checkedAt;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => _check(silent: true));
    _events = getIt<NotificationEvents>().onChanged.listen((_) => _check(silent: true));
    _timer = Timer.periodic(_interval, (_) => _check(silent: true));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _events?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check({bool silent = false}) async {
    final sessionCubit = context.read<SessionCubit>();
    final session = sessionCubit.session;
    if (_checking || session == null) return;
    setState(() => _checking = true);
    try {
      final refreshed = await getIt<RefreshOwnerStatus>()(session);
      _checkedAt = DateTime.now();
      if (refreshed != session) await sessionCubit.update(refreshed);
    } catch (error) {
      if (!silent && mounted) AppToast.error(context, AppException.from(error).message);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmLabel: AppStrings.logout,
      destructive: true,
    );
    if (confirmed && mounted) await SessionNavigator.logout(context);
  }

  Future<void> _editProfile() => context.router.push(const OwnerProfileFormRoute());

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listenWhen: (previous, current) =>
          previous.session?.hotelChain?.approvalStatus !=
          current.session?.hotelChain?.approvalStatus,
      listener: (context, state) {
        if (state.session?.hotelChain?.isApproved ?? false) {
          AppToast.success(context, PartnerStrings.approvedToast);
          context.router.replaceAll([const OwnerShellRoute()]);
        }
      },
      builder: (context, state) {
        final session = state.session;
        final chain = session?.hotelChain;
        if (session == null || chain == null) {
          return const Scaffold(body: AppLoadingView());
        }
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _check,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Header(chain: chain, onLogout: _logout),
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Padding(
                    padding: AppSpacing.pageHorizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatusCard(
                          chain: chain,
                          checking: _checking,
                          checkedAt: _checkedAt,
                          onCheck: _check,
                          onResubmit: _editProfile,
                        ),
                        const Gap(AppSpacing.md),
                        if (chain.approvalStatus == ApprovalStatus.pending) ...[
                          _ReviewSteps(chain: chain),
                          const Gap(AppSpacing.lg),
                        ],
                        _SubmittedDetails(
                          chain: chain,
                          username: session.username,
                          onEdit: _editProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.chain, required this.onLogout});

  final HotelChain chain;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final onDarkMuted = AppColors.onPrimary.withValues(alpha: 0.82);
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 60),
      child: Row(
        children: [
          const BrandMark(size: 44, onDark: true),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Role.hotelOwner.label,
                  style: AppTextStyles.captionStrong.colored(onDarkMuted),
                ),
                Text(
                  chain.name,
                  style: AppTextStyles.title.colored(AppColors.onPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const NotificationBell(onDark: true),
          IconButton(
            tooltip: AppStrings.logout,
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.chain,
    required this.checking,
    required this.checkedAt,
    required this.onCheck,
    required this.onResubmit,
  });

  final HotelChain chain;
  final bool checking;
  final DateTime? checkedAt;
  final VoidCallback onCheck;
  final VoidCallback onResubmit;

  @override
  Widget build(BuildContext context) {
    final rejected = chain.approvalStatus == ApprovalStatus.rejected;
    final reason = chain.rejectionReason;
    return AppCard(
      elevated: true,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox.square(
              dimension: 112,
              child: AppIllustration(
                type: rejected ? AppIllustrationType.rejected : AppIllustrationType.pending,
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          Center(child: StatusBadge.approval(chain.approvalStatus)),
          const Gap(AppSpacing.sm),
          Text(
            rejected ? PartnerStrings.rejectedTitle : PartnerStrings.pendingTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
          const Gap(AppSpacing.xs),
          Text(
            rejected ? PartnerStrings.rejectedMessage : PartnerStrings.pendingMessage(chain.email),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          if (reason != null) ...[
            const Gap(AppSpacing.md),
            ReviewNote(
              title: rejected ? PartnerStrings.rejectionReason : PartnerStrings.previousRejection,
              text: reason,
              tone: rejected ? StatusTone.danger : StatusTone.info,
              caption: rejected && chain.reviewedAt != null
                  ? PartnerStrings.reviewedOn(Fmt.dateTime(chain.reviewedAt))
                  : null,
            ),
          ],
          const Gap(AppSpacing.lg),
          if (rejected)
            AppButton(
              label: PartnerStrings.resubmit,
              icon: Icons.edit_note_rounded,
              expand: true,
              onPressed: onResubmit,
            )
          else ...[
            AppButton.tonal(
              label: PartnerStrings.checkStatus,
              icon: Icons.refresh_rounded,
              expand: true,
              loading: checking,
              onPressed: onCheck,
            ),
            const Gap(AppSpacing.xs),
            Text(
              checkedAt == null
                  ? PartnerStrings.autoCheck
                  : PartnerStrings.checkedAt(Fmt.dateTime(checkedAt)),
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

/// Ba bước của hồ sơ — đánh số vì thứ tự có ý nghĩa.
class _ReviewSteps extends StatelessWidget {
  const _ReviewSteps({required this.chain});

  final HotelChain chain;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        PartnerStrings.stepSubmitted,
        chain.submittedAt == null ? null : Fmt.dateTime(chain.submittedAt),
        _StepState.done,
      ),
      (PartnerStrings.stepReview, PartnerStrings.stepReviewHint, _StepState.current),
      (PartnerStrings.stepStart, PartnerStrings.stepStartHint, _StepState.upcoming),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              number: i + 1,
              title: steps[i].$1,
              subtitle: steps[i].$2,
              state: steps[i].$3,
              last: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.last,
  });

  final int number;
  final String title;
  final String? subtitle;
  final _StepState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final (fill, border) = switch (state) {
      _StepState.done => (AppColors.primary, AppColors.primary),
      _StepState.current => (AppColors.warningSoft, AppColors.warning),
      _StepState.upcoming => (AppColors.surface, AppColors.line),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1.5),
                ),
                child: switch (state) {
                  _StepState.done =>
                    const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary),
                  _StepState.current =>
                    const Icon(Icons.hourglass_top_rounded, size: 15, color: AppColors.warning),
                  _StepState.upcoming => Text(
                      '$number',
                      style: AppTextStyles.captionStrong.colored(AppColors.inkTertiary),
                    ),
                },
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: state == _StepState.done ? AppColors.primary : AppColors.line,
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: state == _StepState.upcoming
                        ? AppTextStyles.bodyMedium.colored(AppColors.inkSecondary)
                        : AppTextStyles.bodyStrong,
                  ),
                  if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedDetails extends StatelessWidget {
  const _SubmittedDetails({
    required this.chain,
    required this.username,
    required this.onEdit,
  });

  final HotelChain chain;
  final String username;
  final VoidCallback onEdit;

  static String _orPlaceholder(String value) =>
      value.trim().isEmpty ? AppStrings.notUpdated : value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: PartnerStrings.submittedDetails,
          actionLabel: PartnerStrings.editProfile,
          onAction: onEdit,
        ),
        const Gap(AppSpacing.xs),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.apartment_rounded,
                label: PartnerStrings.labelHotel,
                value: chain.name,
              ),
              InfoRow(
                icon: Icons.location_on_outlined,
                label: PartnerStrings.labelAddress,
                value: _orPlaceholder(chain.address),
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                label: PartnerStrings.labelPhone,
                value: _orPlaceholder(chain.phone),
              ),
              InfoRow(
                icon: Icons.person_outline_rounded,
                label: PartnerStrings.labelOwner,
                value: _orPlaceholder(chain.ownerName),
              ),
              InfoRow(
                icon: Icons.mail_outline_rounded,
                label: PartnerStrings.labelEmail,
                value: _orPlaceholder(chain.email),
              ),
              InfoRow(
                icon: Icons.badge_outlined,
                label: PartnerStrings.labelAccount,
                value: '@$username',
              ),
            ],
          ),
        ),
        if (chain.description.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          const SectionHeader(title: PartnerStrings.labelAbout),
          const Gap(AppSpacing.xxs),
          ExpandableText(chain.description),
        ],
        const Gap(AppSpacing.xl),
      ],
    );
  }
}
