import 'package:flutter/widgets.dart';

/// Khoảng trống cố định, dùng được trong cả Row lẫn Column.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
