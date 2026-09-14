import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/validation_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../employee/domain/entities/employee.dart';
import '../../employee/domain/usecases/employee_usecases.dart';
import '../data/payroll_session_store.dart';
import '../domain/entities/payroll_entry.dart';
import '../domain/usecases/payroll_usecases.dart';

class PayrollState extends Equatable {
  const PayrollState({
    this.employees = const LoadState(),
    this.entries = const [],
  });

  final LoadState<List<Employee>> employees;
  final List<PayrollEntry> entries;

  PayrollState copyWith({
    LoadState<List<Employee>>? employees,
    List<PayrollEntry>? entries,
  }) =>
      PayrollState(
        employees: employees ?? this.employees,
        entries: entries ?? this.entries,
      );

  @override
  List<Object?> get props => [employees, entries];
}

@injectable
class PayrollCubit extends Cubit<PayrollState> {
  PayrollCubit(this._getEmployees, this._savePayroll, this._store)
      : super(const PayrollState());

  final GetBranchEmployees _getEmployees;
  final SavePayroll _savePayroll;
  final PayrollSessionStore _store;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    emit(state.copyWith(entries: _store.read(hotelId)));
    return loadEmployees();
  }

  Future<void> loadEmployees() async {
    emit(state.copyWith(employees: state.employees.toLoading()));
    try {
      final employees = await _getEmployees(_hotelId);
      if (!isClosed) emit(state.copyWith(employees: state.employees.toSuccess(employees)));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          employees: state.employees.toFailure(AppException.from(error).message),
        ));
      }
    }
  }

  Future<ActionResult<PayrollEntry>> save(PayrollEntry entry) async {
    final result = await runAction(() => _savePayroll(entry));
    if (result.isSuccess) {
      _store.upsert(_hotelId, result.value!);
      if (!isClosed) emit(state.copyWith(entries: _store.read(_hotelId)));
    }
    return result;
  }
}

/// Ghi nhận lương tháng cho nhân viên cơ sở.
@RoutePage()
class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PayrollCubit>()..start(hotelId),
      child: const _PayrollView(),
    );
  }
}

class _PayrollView extends StatefulWidget {
  const _PayrollView();

  @override
  State<_PayrollView> createState() => _PayrollViewState();
}

class _PayrollViewState extends State<_PayrollView> {
  final _form = GlobalKey<FormState>();
  final _total = TextEditingController();
  int? _employeeId;
  DateTime _month = DateOnly.startOfMonth(DateOnly.today());
  PayrollStatus _status = PayrollStatus.approved;
  bool _saving = false;

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }

  void _selectEmployee(List<Employee> employees, int? id) {
    final employee = employees.firstWhereOrNull((item) => item.id == id);
    setState(() {
      _employeeId = id;
      if (employee != null) _total.text = ThousandsInputFormatter.format(employee.salary);
    });
  }

  Future<void> _create(List<Employee> employees) async {
    if (!_form.currentState!.validate()) return;
    final employee = employees.firstWhereOrNull((item) => item.id == _employeeId);
    if (employee == null) return;
    setState(() => _saving = true);
    final result = await context.read<PayrollCubit>().save(
          PayrollEntry(
            employeeId: employee.id,
            employeeName: employee.fullName,
            month: _month,
            totalSalary: Validators.parseMoney(_total.text) ?? 0,
            status: _status,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, WorkspaceStrings.payrollCreated);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  Future<void> _changeStatus(PayrollEntry entry) async {
    final status = await AppDialogs.choose<PayrollStatus>(
      context,
      title: WorkspaceStrings.updatePayroll,
      choices: [
        for (final value in PayrollStatus.values)
          AppChoice(
            value: value,
            label: value.label,
            icon: value == entry.status
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
          ),
      ],
    );
    if (status == null || status == entry.status || !mounted) return;
    final cubit = context.read<PayrollCubit>();
    await AppAction.run(
      context,
      () => cubit.save(entry.copyWith(status: status)),
      successMessage: WorkspaceStrings.payrollUpdated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollCubit, PayrollState>(
      builder: (context, state) {
        final cubit = context.read<PayrollCubit>();
        return AppPage(
          title: WorkspaceStrings.payrollTitle,
          body: RefreshIndicator(
            onRefresh: cubit.loadEmployees,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Text(WorkspaceStrings.payrollIntro, style: AppTextStyles.bodySmall),
                const Gap(AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: IconText(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.info,
                    text: WorkspaceStrings.payrollGap,
                    maxLines: 4,
                    style: AppTextStyles.bodySmall.colored(AppColors.info),
                  ),
                ),
                const Gap(AppSpacing.md),
                AppCard(child: _formContent(state, cubit)),
                const Gap(AppSpacing.xl),
                SectionHeader(
                  title: WorkspaceStrings.sessionPayrolls,
                  subtitle: state.entries.isEmpty
                      ? null
                      : AppStrings.itemsCount(state.entries.length),
                ),
                const Gap(AppSpacing.sm),
                if (state.entries.isEmpty)
                  Text(WorkspaceStrings.payrollEmpty, style: AppTextStyles.bodySmall)
                else
                  for (final entry in state.entries) ...[
                    _PayrollEntryTile(entry: entry, onTap: () => _changeStatus(entry)),
                    const Gap(AppSpacing.xs),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formContent(PayrollState state, PayrollCubit cubit) {
    final employees = state.employees.data;
    if (employees == null) {
      return state.employees.isFailure
          ? AppErrorView(message: state.employees.error!, onRetry: cubit.loadEmployees)
          : const AppLoadingView();
    }
    if (employees.isEmpty) {
      return Text(WorkspaceStrings.noEmployees, style: AppTextStyles.bodySmall);
    }
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdownField<int>(
            label: WorkspaceStrings.employee,
            prefixIcon: Icons.badge_outlined,
            items: employees.map((item) => item.id).toList(),
            value: _employeeId,
            itemLabel: (id) {
              final employee = employees.firstWhereOrNull((item) => item.id == id);
              if (employee == null) return '#$id';
              return employee.positionName.isEmpty
                  ? employee.fullName
                  : '${employee.fullName} · ${employee.positionName}';
            },
            validator: (value) => value == null ? ValidationStrings.required : null,
            onChanged: (id) => _selectEmployee(employees, id),
          ),
          const Gap(AppSpacing.sm),
          _MonthField(month: _month, onChanged: (month) => setState(() => _month = month)),
          const Gap(AppSpacing.sm),
          AppMoneyField(
            controller: _total,
            label: WorkspaceStrings.totalSalary,
            validator: Validators.money,
          ),
          const Gap(AppSpacing.sm),
          AppDropdownField<PayrollStatus>(
            label: WorkspaceStrings.payrollStatus,
            prefixIcon: Icons.flag_outlined,
            items: PayrollStatus.values,
            value: _status,
            itemLabel: (status) => status.label,
            onChanged: (status) => setState(() => _status = status ?? _status),
          ),
          const Gap(AppSpacing.md),
          AppButton(
            label: WorkspaceStrings.createPayroll,
            icon: Icons.add_rounded,
            expand: true,
            loading: _saving,
            onPressed: () => _create(employees),
          ),
        ],
      ),
    );
  }
}

/// Chọn tháng lương bằng hai nút lùi/tiến — không cho chọn tháng tương lai.
class _MonthField extends StatelessWidget {
  const _MonthField({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = DateOnly.startOfMonth(DateOnly.today());
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: WorkspaceStrings.month,
        prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
        contentPadding: EdgeInsets.fromLTRB(12, 4, 4, 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(Fmt.monthYear(month.month, month.year), style: AppTextStyles.body),
          ),
          IconButton(
            tooltip: AppStrings.back,
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: AppStrings.next,
            visualDensity: VisualDensity.compact,
            onPressed: month.isBefore(current)
                ? () => onChanged(DateTime(month.year, month.month + 1))
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _PayrollEntryTile extends StatelessWidget {
  const _PayrollEntryTile({required this.entry, required this.onTap});

  final PayrollEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(name: entry.employeeName, size: 40),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.employeeName, style: AppTextStyles.bodyStrong),
                Text(
                  Fmt.monthYear(entry.month.month, entry.month.year),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.money(entry.totalSalary),
                style: AppTextStyles.tabular.weight(FontWeight.w600),
              ),
              const Gap(4),
              StatusBadge.payroll(entry.status, dense: true),
            ],
          ),
        ],
      ),
    );
  }
}
