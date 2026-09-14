import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_enums.dart';
import '../../hotel/presentation/branch/branch_cubit.dart';

export '../../hotel/presentation/branch/branch_cubit.dart';

/// Cơ sở đang làm việc và vai trò của người dùng, cho mọi tab trong không gian làm việc.
class WorkspaceScope extends InheritedWidget {
  const WorkspaceScope({
    super.key,
    required this.hotelId,
    required this.role,
    required super.child,
  });

  final int hotelId;
  final Role role;

  /// Quản lý trở lên: xoá dữ liệu, xem báo cáo, quản lý nhân sự.
  bool get canManage => role.isManagerOrAbove;

  static WorkspaceScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WorkspaceScope>();
    assert(scope != null, 'WorkspaceScope không có trong cây widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(WorkspaceScope oldWidget) =>
      hotelId != oldWidget.hotelId || role != oldWidget.role;
}

extension BranchNameX on BuildContext {
  /// Tên cơ sở hiện tại, `null` khi đang tải.
  String? get branchName =>
      select((BranchCubit cubit) => cubit.state.data?.hotel.name);
}
