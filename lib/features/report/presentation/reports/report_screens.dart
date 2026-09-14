import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/text/report_strings.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../shell/presentation/workspace_scope.dart';
import '../../domain/entities/report_entities.dart';
import 'reports_view.dart';

/// Tab Báo cáo trong không gian làm việc của quản lý.
@RoutePage()
class BranchReportsScreen extends StatelessWidget {
  const BranchReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ReportsView(
      scope: BranchReportScope(WorkspaceScope.of(context).hotelId),
      title: ReportStrings.branchReportsTitle,
      subtitle: context.branchName,
    );
  }
}

/// Tab Báo cáo của chủ khách sạn — số liệu gộp mọi cơ sở trong chuỗi.
@RoutePage()
class ChainReportsScreen extends StatelessWidget {
  const ChainReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chain = context.select((SessionCubit cubit) => cubit.state.session?.hotelChain);
    if (chain == null) return const SizedBox.shrink();
    return ReportsView(
      scope: ChainReportScope(chain.id),
      title: ReportStrings.chainReportsTitle,
      subtitle: chain.name,
    );
  }
}
