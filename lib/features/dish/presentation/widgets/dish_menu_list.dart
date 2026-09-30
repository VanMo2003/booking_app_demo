import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/enum_labels.dart';
import '../../../../core/text/menu_strings.dart';
import '../../domain/entities/dish.dart';

/// Thực đơn: dải chip lọc nhóm món + danh sách. "Tất cả" gom theo nhóm với
/// tiêu đề nhóm; chọn một nhóm thì chỉ còn món của nhóm đó.
class DishMenuList extends StatefulWidget {
  const DishMenuList({
    super.key,
    required this.dishes,
    required this.itemBuilder,
    required this.onRefresh,
    this.header,
  });

  final List<Dish> dishes;
  final Widget Function(BuildContext context, Dish dish) itemBuilder;
  final Future<void> Function() onRefresh;

  /// Khối đầu danh sách (lưu ý chế độ xem…).
  final Widget? header;

  @override
  State<DishMenuList> createState() => _DishMenuListState();
}

class _DishMenuListState extends State<DishMenuList> {
  /// `null` = tất cả.
  DishCategory? _category;

  @override
  Widget build(BuildContext context) {
    final groups = widget.dishes.byCategory();
    // Nhóm đang chọn vừa hết món (xoá, đổi nhóm) → quay về "Tất cả".
    final selected = groups.containsKey(_category) ? _category : null;
    final options = <DishCategory?>[null, ...groups.keys];
    final visible = selected == null ? groups : {selected: groups[selected]!};
    return Column(
      children: [
        if (widget.header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: widget.header,
          ),
        const Gap(AppSpacing.xs),
        ChoiceChipBar<DishCategory?>(
          options: options,
          selected: selected,
          labelOf: (category) => category?.label ?? MenuStrings.all,
          countOf: (category) =>
              category == null ? widget.dishes.length : groups[category]!.length,
          onSelected: (category) => setState(() => _category = category),
        ),
        const Gap(AppSpacing.xs),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, AppSpacing.bottomBarClearance),
              children: [
                for (final entry in visible.entries) ...[
                  if (selected == null)
                    GroupLabel(
                      '${entry.key.label} · ${entry.value.length}',
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    ),
                  for (final dish in entry.value) ...[
                    widget.itemBuilder(context, dish),
                    const Gap(AppSpacing.xs),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
