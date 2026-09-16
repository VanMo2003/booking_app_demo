import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/external_actions.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/employee.dart';
import '../domain/usecases/employee_usecases.dart';

@injectable
class EmployeesCubit extends LoadCubit<List<Employee>> {
  EmployeesCubit(this._getEmployees);

  final GetBranchEmployees _getEmployees;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getEmployees(_hotelId));
}

enum _EmployeeAction { edit, call, delete }

/// Nhân viên của cơ sở — quản lý trở lên. Quản trị viên chỉ xem (tạo nhân viên
/// là tạo tài khoản đăng nhập).
@RoutePage()
class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EmployeesCubit>()..start(hotelId),
      child: _EmployeesView(hotelId: hotelId),
    );
  }
}

class _EmployeesView extends StatelessWidget {
  const _EmployeesView({required this.hotelId});

  final int hotelId;

  Future<void> _openForm(BuildContext context, {Employee? employee}) async {
    final saved = await context.router.push<bool>(
      EmployeeFormRoute(hotelId: hotelId, employee: employee),
    );
    if (saved == true && context.mounted) await context.read<EmployeesCubit>().load();
  }

  Future<void> _showActions(
    BuildContext context,
    Employee employee, {
    required bool canEdit,
  }) async {
    final choices = [
      if (canEdit)
        const AppChoice(
          value: _EmployeeAction.edit,
          label: WorkspaceStrings.editEmployee,
          icon: Icons.edit_outlined,
        ),
      if (employee.phoneNumber.isNotEmpty)
        AppChoice(
          value: _EmployeeAction.call,
          label: '${AppStrings.call} ${employee.phoneNumber}',
          icon: Icons.call_outlined,
        ),
      if (canEdit)
        const AppChoice(
          value: _EmployeeAction.delete,
          label: AppStrings.delete,
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
    ];
    if (choices.isEmpty) return;
    final action = await AppDialogs.choose<_EmployeeAction>(
      context,
      title: employee.fullName,
      choices: choices,
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _EmployeeAction.edit:
        await _openForm(context, employee: employee);
      case _EmployeeAction.call:
        await ExternalActions.call(employee.phoneNumber);
      case _EmployeeAction.delete:
        await _delete(context, employee);
    }
  }

  Future<void> _delete(BuildContext context, Employee employee) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(employee.fullName),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteEmployee>()(employee.id)),
      successMessage: WorkspaceStrings.employeeDeleted,
    );
    if (result.isSuccess && context.mounted) await context.read<EmployeesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = context.select(
      (SessionCubit cubit) => cubit.state.role?.canEditBranchContent ?? false,
    );
    return BlocBuilder<EmployeesCubit, LoadState<List<Employee>>>(
      builder: (context, state) {
        final cubit = context.read<EmployeesCubit>();
        return AppPage(
          title: WorkspaceStrings.employeesTitle,
          subtitle: state.hasData ? WorkspaceStrings.employeesCount(state.data!.length) : null,
          floatingActionButton: !canEdit || (state.data?.isEmpty ?? true)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text(WorkspaceStrings.addEmployee),
                ),
          body: LoadStateView<List<Employee>>(
            state: state,
            onRetry: cubit.load,
            isEmpty: (data) => data.isEmpty,
            empty: AppEmptyView(
              icon: Icons.badge_outlined,
              title: WorkspaceStrings.employeesEmpty,
              addLabel: WorkspaceStrings.addEmployee,
              onAdd: canEdit ? () => _openForm(context) : null,
            ),
            builder: (context, employees) => RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, AppSpacing.bottomBarClearance),
                itemCount: employees.length + (canEdit ? 0 : 1),
                separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                itemBuilder: (context, index) {
                  if (!canEdit && index == 0) {
                    return const NoticeBanner(
                      text: WorkspaceStrings.readOnlyNotice,
                      icon: Icons.visibility_outlined,
                    );
                  }
                  final employee = employees[canEdit ? index : index - 1];
                  return _EmployeeTile(
                    employee: employee,
                    onTap: () => _showActions(context, employee, canEdit: canEdit),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final Employee employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (employee.positionName.isNotEmpty) employee.positionName,
      if (employee.phoneNumber.isNotEmpty) employee.phoneNumber,
    ].join(' · ');
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(name: employee.fullName, imagePath: employee.pathImage, size: 44),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.money(employee.salary),
                style: AppTextStyles.tabular.weight(FontWeight.w600),
              ),
              Text(WorkspaceStrings.salaryLabel, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
