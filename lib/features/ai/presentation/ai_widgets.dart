import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

/// Lối vào "Hỏi AI tìm phòng" dưới ô tìm kiếm ở trang Khám phá; ẩn khi máy chủ chưa bật AI.
class AiSearchEntry extends StatelessWidget {
  const AiSearchEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: getIt<AiAvailability>().enabled,
      builder: (context, enabled, _) {
        if (!enabled) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Material(
            color: AppColors.accentSoft,
            borderRadius: AppRadius.mdAll,
            child: InkWell(
              borderRadius: AppRadius.mdAll,
              onTap: () => context.rootRouter.push(AiSearchRoute()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AiStrings.searchEntry, style: AppTextStyles.bodyStrong),
                          Text(
                            AiStrings.searchEntryHint,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Đầu hộp thư của một cơ sở: chủ khách sạn / quản lý bật-tắt trợ lý AI tự trả lời;
/// nhân viên chỉ thấy dải báo khi đang bật. Ẩn hẳn khi máy chủ chưa bật AI.
class AiAutoReplyBar extends StatefulWidget {
  const AiAutoReplyBar({super.key, required this.hotelId});

  final int hotelId;

  @override
  State<AiAutoReplyBar> createState() => _AiAutoReplyBarState();
}

class _AiAutoReplyBarState extends State<AiAutoReplyBar> {
  AiBranchSettings? _settings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await runAction(() => getIt<GetAiBranchSettings>()(widget.hotelId));
    if (mounted && result.value != null) setState(() => _settings = result.value);
  }

  Future<void> _toggle(bool value) async {
    setState(() => _saving = true);
    final result = await runAction(() => getIt<SetAiAutoReply>()(widget.hotelId, value));
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.value != null) _settings = result.value;
    });
    if (result.isSuccess) {
      AppToast.success(context, value ? AiStrings.autoReplyOn : AiStrings.autoReplyOff);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null || !settings.aiEnabled) return const SizedBox.shrink();
    final role = context.select((SessionCubit cubit) => cubit.state.role);
    final canChange = role == Role.hotelOwner || role == Role.hotelManager;
    if (!canChange) {
      return !settings.autoReply
          ? const SizedBox.shrink()
          : const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: NoticeBanner(
                text: AiStrings.autoReplyActiveForStaff,
                icon: Icons.auto_awesome_rounded,
                tone: StatusTone.brand,
              ),
            );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
        color: settings.autoReply ? AppColors.accentSoft : null,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.autoReply,
          onChanged: _saving ? null : _toggle,
          secondary: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
          title: Text(AiStrings.autoReplyTitle, style: AppTextStyles.bodyStrong),
          subtitle: Text(
            AiStrings.autoReplyHint(settings.autoReplyDelaySeconds),
            style: AppTextStyles.caption,
          ),
        ),
      ),
    );
  }
}
