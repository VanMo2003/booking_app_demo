import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/text/ai_strings.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';
import 'ai_widgets.dart';

/// Nút "AI soạn mô tả" cho biểu mẫu phòng, món ăn hoặc dịch vụ.
///
/// Chỉ điền vào ô nhập — quản lý đọc lại rồi tự lưu, nên không có chữ nào của AI lên trang mà người
/// chưa đọc. Mô tả được dựng từ chính dữ liệu dòng đó ở máy chủ, nên nút cần [id]: mục chưa lưu lần
/// nào thì chưa có gì để đọc, và nút nói thẳng điều đó thay vì gọi API rồi báo lỗi.
class AiDescribeButton extends StatefulWidget {
  const AiDescribeButton({
    super.key,
    required this.kind,
    required this.id,
    required this.controller,
    this.enabled = true,
  });

  final DescribableKind kind;

  /// Mã dòng; null khi đang thêm mới và chưa lưu.
  final int? id;

  /// Ô mô tả sẽ được điền.
  final TextEditingController controller;

  final bool enabled;

  @override
  State<AiDescribeButton> createState() => _AiDescribeButtonState();
}

class _AiDescribeButtonState extends State<AiDescribeButton> {
  bool _drafting = false;

  Future<void> _draft() async {
    final id = widget.id;
    if (id == null) {
      AppToast.error(context, AiStrings.describeNeedsSave);
      return;
    }
    if (widget.controller.text.trim().isNotEmpty) {
      final replace = await AppDialogs.confirm(
        context,
        title: AiStrings.describeOverwriteTitle,
        message: AiStrings.describeOverwriteMessage,
        confirmLabel: AiStrings.describeOverwriteConfirm,
      );
      if (replace != true || !mounted) return;
    }
    setState(() => _drafting = true);
    final result = await runAction(
      () => getIt<DraftDescription>()(kind: widget.kind, id: id),
    );
    if (!mounted) return;
    setState(() => _drafting = false);
    final draft = result.value;
    if (draft == null) {
      AppToast.error(context, result.error!);
      return;
    }
    widget.controller.text = draft.description;
    AppToast.success(context, AiStrings.describeDone);
  }

  @override
  Widget build(BuildContext context) {
    return AiEnabled(
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppButton.text(
          label: AiStrings.describeAction,
          size: AppButtonSize.small,
          icon: Icons.auto_awesome_rounded,
          loading: _drafting,
          onPressed: widget.enabled ? _draft : null,
        ),
      ),
    );
  }
}
