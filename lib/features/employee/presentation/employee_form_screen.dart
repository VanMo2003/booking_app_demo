import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/explore_strings.dart';
import '../../../core/text/validation_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../catalog/domain/entities/catalog_item.dart';
import '../../catalog/domain/usecases/catalog_usecases.dart';
import '../data/models/employee_models.dart';
import '../domain/entities/employee.dart';
import '../domain/usecases/employee_usecases.dart';

/// Thêm nhân viên (kèm tài khoản STAFF) hoặc sửa hồ sơ. Trả `true` khi đã lưu.
@RoutePage()
class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key, required this.hotelId, this.employee});

  final int hotelId;
  final Employee? employee;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  late final _fullName = TextEditingController(text: widget.employee?.fullName);
  late final _phone = TextEditingController(text: widget.employee?.phoneNumber);
  late final _salary = TextEditingController(
    text: ThousandsInputFormatter.format(widget.employee?.salary),
  );
  late String? _gender = _nonEmpty(widget.employee?.gender);
  late String? _hometown = _nonEmpty(widget.employee?.hometown);
  late DateTime? _dateOfBirth = widget.employee?.dateOfBirth;
  int? _positionId;
  late Future<List<CatalogItem>> _positions = _loadPositions();
  bool _saving = false;

  bool get _isEdit => widget.employee != null;

  static String? _nonEmpty(String? value) => (value ?? '').isEmpty ? null : value;

  Future<List<CatalogItem>> _loadPositions() async {
    final items = await getIt<GetCatalog>()(CatalogKind.position);
    final current = widget.employee?.positionName;
    _positionId ??= items.firstWhereOrNull((item) => item.name == current)?.id;
    return items;
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _fullName.dispose();
    _phone.dispose();
    _salary.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final positionId = _positionId;
    if (positionId == null) {
      AppToast.error(context, WorkspaceStrings.noPositions);
      return;
    }
    setState(() => _saving = true);
    final employee = widget.employee;
    final result = await runAction(
      () => getIt<SaveEmployee>()(
        EmployeeRequest(
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          gender: _gender ?? '',
          hometown: _hometown ?? '',
          salary: Validators.parseMoney(_salary.text) ?? 0,
          positionId: positionId,
          dateOfBirth: _dateOfBirth,
          pathImage: employee?.pathImage,
          username: _isEdit ? null : _username.text.trim(),
          password: _isEdit ? null : _password.text,
          hotelId: _isEdit ? null : widget.hotelId,
        ),
        id: employee?.id,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, WorkspaceStrings.employeeSaved);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _isEdit ? WorkspaceStrings.editEmployee : WorkspaceStrings.addEmployee,
      body: FutureBuilder<List<CatalogItem>>(
        future: _positions,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppErrorView(
              message: AppException.from(snapshot.error!).message,
              onRetry: () => setState(() => _positions = _loadPositions()),
            );
          }
          if (!snapshot.hasData) return const AppLoadingView();
          final positions = snapshot.data!;
          return Form(
            key: _form,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                if (!_isEdit) ...[
                  const GroupLabel(WorkspaceStrings.loginAccount),
                  AppTextField(
                    controller: _username,
                    label: AuthStrings.username,
                    helper: AuthStrings.usernameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: Validators.username,
                  ),
                  const Gap(AppSpacing.sm),
                  AppPasswordField(
                    controller: _password,
                    label: AuthStrings.password,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),
                  const Gap(AppSpacing.xs),
                  const IconText(
                    icon: Icons.info_outline_rounded,
                    text: WorkspaceStrings.accountNote,
                    maxLines: 2,
                  ),
                  const Gap(AppSpacing.xl),
                ],
                const GroupLabel(WorkspaceStrings.personalInfo),
                AppTextField(
                  controller: _fullName,
                  label: ExploreStrings.fullName,
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.required(),
                ),
                const Gap(AppSpacing.sm),
                AppTextField(
                  controller: _phone,
                  label: ExploreStrings.phone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  validator: Validators.phone,
                ),
                const Gap(AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppDropdownField<String>(
                        label: ExploreStrings.gender,
                        items: AppConstants.genders,
                        value: _gender,
                        itemLabel: (item) => item,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: AppDateField(
                        label: WorkspaceStrings.dateOfBirth,
                        value: _dateOfBirth,
                        icon: Icons.cake_outlined,
                        lastDate: DateOnly.today(),
                        onChanged: (value) => setState(() => _dateOfBirth = value),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                AppDropdownField<String>(
                  label: ExploreStrings.hometown,
                  prefixIcon: Icons.home_work_outlined,
                  items: AppConstants.provinces,
                  value: _hometown,
                  itemLabel: (item) => item,
                  onChanged: (value) => setState(() => _hometown = value),
                ),
                const Gap(AppSpacing.xl),
                const GroupLabel(WorkspaceStrings.workInfo),
                if (positions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.warningSoft,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      WorkspaceStrings.noPositions,
                      style: AppTextStyles.bodySmall.colored(AppColors.warning),
                    ),
                  )
                else
                  AppDropdownField<int>(
                    label: WorkspaceStrings.position,
                    prefixIcon: Icons.work_outline_rounded,
                    items: positions.map((item) => item.id).toList(),
                    value: _positionId,
                    itemLabel: (id) =>
                        positions.firstWhereOrNull((item) => item.id == id)?.name ?? '#$id',
                    validator: (value) => value == null ? ValidationStrings.required : null,
                    onChanged: (value) => setState(() => _positionId = value),
                  ),
                const Gap(AppSpacing.sm),
                AppMoneyField(
                  controller: _salary,
                  label: WorkspaceStrings.salary,
                  validator: Validators.money,
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: AppStrings.save,
          expand: true,
          loading: _saving,
          onPressed: _submit,
        ),
      ),
    );
  }
}
