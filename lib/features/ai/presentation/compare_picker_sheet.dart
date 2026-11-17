import 'package:flutter/material.dart';

import '../../../core/component/component.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';

/// Một cơ sở có thể đem đi so sánh — chỉ cần mã và tên, nên chỗ nào có danh sách cơ sở cũng dùng được.
class ComparableHotel {
  const ComparableHotel({required this.id, required this.name, this.subtitle});

  final int id;
  final String name;
  final String? subtitle;
}

/// Bảng chọn 2–4 cơ sở để so sánh. Trả về danh sách mã đã chọn, null khi khách đóng bảng.
Future<List<int>?> showComparePicker(BuildContext context, List<ComparableHotel> hotels) {
  return showModalBottomSheet<List<int>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _ComparePickerSheet(hotels: hotels),
  );
}

class _ComparePickerSheet extends StatefulWidget {
  const _ComparePickerSheet({required this.hotels});

  final List<ComparableHotel> hotels;

  @override
  State<_ComparePickerSheet> createState() => _ComparePickerSheetState();
}

class _ComparePickerSheetState extends State<_ComparePickerSheet> {
  /// Giữ theo thứ tự khách bấm, vì bảng so sánh xếp cột theo thứ tự này.
  final List<int> _picked = [];

  static const _max = 4;
  static const _min = 2;

  void _toggle(int hotelId) {
    setState(() {
      if (_picked.remove(hotelId)) return;
      if (_picked.length < _max) _picked.add(hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AiStrings.comparePick, style: AppTextStyles.subtitle),
            const Gap(AppSpacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final hotel in widget.hotels)
                    CheckboxListTile(
                      value: _picked.contains(hotel.id),
                      // Đủ 4 cơ sở thì khoá những ô chưa chọn, thay vì để khách bấm mà không có gì xảy ra.
                      onChanged: _picked.length >= _max && !_picked.contains(hotel.id)
                          ? null
                          : (_) => _toggle(hotel.id),
                      title: Text(hotel.name, style: AppTextStyles.bodyMedium, maxLines: 2),
                      subtitle: hotel.subtitle == null
                          ? null
                          : Text(hotel.subtitle!, style: AppTextStyles.caption, maxLines: 1),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              ),
            ),
            const Gap(AppSpacing.sm),
            AppButton(
              label: AiStrings.compareGo,
              size: AppButtonSize.small,
              icon: Icons.compare_arrows_rounded,
              expand: true,
              onPressed: _picked.length < _min ? null : () => Navigator.of(context).pop(List.of(_picked)),
            ),
          ],
        ),
      ),
    );
  }
}
