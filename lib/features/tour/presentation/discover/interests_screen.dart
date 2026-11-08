import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/discover_strings.dart';
import '../../data/interest_store.dart';
import '../../domain/entities/travel_theme.dart';

/// Chọn sở thích du lịch. Lần đầu mở app ([onboarding]) có nút "Bỏ qua"; từ mục Tài khoản thì là màn sửa.
/// Đóng lại với `true` khi sở thích vừa được lưu.
@RoutePage()
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final _store = getIt<InterestStore>();
  late Set<TravelTheme> _selected = {..._store.interests};
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await _store.save(_selected.toList());
    if (!mounted) return;
    if (!widget.onboarding) AppToast.success(context, DiscoverStrings.interestsSaved);
    await context.router.maybePop(true);
  }

  Future<void> _skip() async {
    await _store.skip();
    if (mounted) await context.router.maybePop(false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.onboarding ? '' : DiscoverStrings.interestsEdit,
      automaticallyImplyLeading: !widget.onboarding,
      actions: [
        if (widget.onboarding) TextButton(onPressed: _saving ? null : _skip, child: const Text(DiscoverStrings.interestsSkip)),
      ],
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const Icon(Icons.explore_rounded, size: 48, color: AppColors.primary),
          const Gap(AppSpacing.md),
          Text(DiscoverStrings.interestsTitle, style: AppTextStyles.headline),
          const Gap(AppSpacing.xs),
          Text(DiscoverStrings.interestsSubtitle, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.lg),
          ThemeGrid(selected: _selected, onChanged: (next) => setState(() => _selected = next)),
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: widget.onboarding
              ? (_selected.isEmpty
                  ? DiscoverStrings.interestsContinue
                  : DiscoverStrings.interestsContinueCount(_selected.length))
              : DiscoverStrings.interestsSave,
          icon: Icons.check_rounded,
          expand: true,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}

/// Lưới 2 cột các chủ đề, mỗi ô có biểu tượng; chạm để chọn / bỏ chọn.
class ThemeGrid extends StatelessWidget {
  const ThemeGrid({super.key, required this.selected, required this.onChanged});

  final Set<TravelTheme> selected;
  final ValueChanged<Set<TravelTheme>> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.4,
      children: [
        for (final theme in TravelTheme.values)
          _ThemeTile(
            theme: theme,
            selected: selected.contains(theme),
            onTap: () {
              final next = {...selected};
              next.contains(theme) ? next.remove(theme) : next.add(theme);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.theme, required this.selected, required this.onTap});

  final TravelTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.inkSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.lineSoft, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(theme.icon, color: color),
                const Gap(AppSpacing.sm),
                Expanded(child: Text(theme.label, style: AppTextStyles.bodyStrong.colored(color))),
                if (selected) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
