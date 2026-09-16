import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/upload_file.dart';
import '../../../core/style/style.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/validation_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../hotel/data/models/hotel_models.dart';
import '../../hotel/domain/usecases/hotel_usecases.dart';
import '../domain/usecases/hotel_chain_usecases.dart';

/// Chủ khách sạn mở cơ sở mới và giao cho một tài khoản quản lý.
/// Trả `true` khi đã tạo.
@RoutePage()
class BranchFormScreen extends StatefulWidget {
  const BranchFormScreen({super.key, required this.chainId});

  final int chainId;

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final List<UploadFile> _images = [];

  /// Tài khoản vừa tạo trong màn này — giữ lại để lần thử sau không tạo trùng.
  final List<ManagerSummary> _created = [];
  late Future<List<ManagerSummary>> _managers = _loadManagers();
  String? _category;
  String? _managerId;
  bool _newManager = false;
  bool _saving = false;

  String get _ownerUsername => context.read<SessionCubit>().session?.username ?? '';

  Future<List<ManagerSummary>> _loadManagers() async {
    final detail = await getIt<GetHotelChainDetail>()(widget.chainId);
    final managers = await getIt<GetChainManagers>()(detail, ownerUsername: _ownerUsername);
    if (managers.isEmpty && mounted) setState(() => _newManager = true);
    // Cơ sở đầu tiên thường chính là khách sạn đã đăng ký — điền sẵn thông tin hồ sơ.
    if (detail.hotels.isEmpty) {
      if (_name.text.isEmpty) _name.text = detail.chain.name;
      if (_address.text.isEmpty) _address.text = detail.chain.address;
      if (_phone.text.isEmpty) _phone.text = detail.chain.phone;
      if (_description.text.isEmpty) _description.text = detail.chain.description;
    }
    return managers;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _description.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await ImagePickerHelper.pick();
    if (files.isNotEmpty && mounted) setState(() => _images.addAll(files));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_newManager && _managerId == null) {
      AppToast.error(context, ManagementStrings.managerRequired);
      return;
    }
    setState(() => _saving = true);
    var managerId = _managerId;
    if (_newManager) {
      final created = await runAction(
        () => getIt<CreateManagerAccount>()(
          username: _username.text,
          password: _password.text,
          ownerUsername: _ownerUsername,
        ),
      );
      if (!mounted) return;
      if (!created.isSuccess) {
        setState(() => _saving = false);
        AppToast.error(context, created.error!);
        return;
      }
      final account = created.value!;
      managerId = account.id;
      setState(() {
        _created.add(ManagerSummary(account: account, branches: const []));
        _managerId = account.id;
        _newManager = false;
      });
    }
    final accountId = managerId!;
    final result = await runAction(
      () => getIt<CreateBranch>()(
        HotelCreateRequest(
          name: _name.text.trim(),
          address: _address.text.trim(),
          phone: _phone.text.trim(),
          category: _category ?? AppConstants.hotelCategories.first,
          accountId: accountId,
          hotelChainId: widget.chainId,
          description: _description.text.trim(),
        ),
        _images,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, ManagementStrings.branchCreated);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: ManagementStrings.branchFormTitle,
      body: FutureBuilder<List<ManagerSummary>>(
        future: _managers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppFailureView.fromError(
              snapshot.error!,
              onRetry: () => setState(() => _managers = _loadManagers()),
            );
          }
          if (!snapshot.hasData) return const AppLoadingView();
          final managers = [...snapshot.data!, ..._created];
          return Form(
            key: _form,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                const GroupLabel(WorkspaceStrings.branchInfoTitle),
                AppTextField(
                  controller: _name,
                  label: WorkspaceStrings.branchName,
                  prefixIcon: Icons.storefront_outlined,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.required(),
                ),
                const Gap(AppSpacing.sm),
                AppTextField(
                  controller: _address,
                  label: WorkspaceStrings.address,
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                  validator: Validators.required(),
                ),
                const Gap(AppSpacing.sm),
                AppTextField(
                  controller: _phone,
                  label: WorkspaceStrings.phone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.required(),
                ),
                const Gap(AppSpacing.sm),
                AppDropdownField<String>(
                  label: WorkspaceStrings.category,
                  prefixIcon: Icons.category_outlined,
                  items: AppConstants.hotelCategories,
                  value: _category,
                  itemLabel: (item) => item,
                  validator: (value) => value == null ? ValidationStrings.required : null,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const Gap(AppSpacing.sm),
                AppTextField(
                  controller: _description,
                  label: WorkspaceStrings.description,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const Gap(AppSpacing.xl),
                const GroupLabel(ManagementStrings.branchManager),
                SelectableCard(
                  multiple: false,
                  selected: !_newManager,
                  enabled: managers.isNotEmpty,
                  onTap: () => setState(() => _newManager = false),
                  child: Text(ManagementStrings.existingManager, style: AppTextStyles.bodyStrong),
                ),
                const Gap(AppSpacing.xs),
                SelectableCard(
                  multiple: false,
                  selected: _newManager,
                  onTap: () => setState(() => _newManager = true),
                  child: Text(ManagementStrings.newManager, style: AppTextStyles.bodyStrong),
                ),
                const Gap(AppSpacing.sm),
                if (_newManager) ...[
                  AppTextField(
                    controller: _username,
                    label: ManagementStrings.managerUsername,
                    helper: AuthStrings.usernameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: Validators.username,
                  ),
                  const Gap(AppSpacing.sm),
                  AppPasswordField(
                    controller: _password,
                    label: ManagementStrings.managerPassword,
                    validator: Validators.password,
                  ),
                ] else if (managers.isEmpty)
                  Text(ManagementStrings.noManagersYet, style: AppTextStyles.bodySmall)
                else
                  AppDropdownField<String>(
                    label: ManagementStrings.manager,
                    prefixIcon: Icons.manage_accounts_outlined,
                    items: managers.map((manager) => manager.account.id).toList(),
                    value: _managerId,
                    itemLabel: (id) {
                      final manager = managers.firstWhereOrNull((item) => item.account.id == id);
                      return manager == null
                          ? id
                          : '${manager.account.username} · ${ManagementStrings.managedBranches(manager.branches.length)}';
                    },
                    validator: (value) => value == null ? ManagementStrings.managerRequired : null,
                    onChanged: (value) => setState(() => _managerId = value),
                  ),
                const Gap(AppSpacing.xl),
                const SectionHeader(title: ManagementStrings.branchPhotos),
                const Gap(AppSpacing.sm),
                ImageGallery(
                  picked: _images,
                  onAdd: _pickImages,
                  onRemovePicked: (index) => setState(() => _images.removeAt(index)),
                  addLabel: ManagementStrings.pickPhotos,
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: ManagementStrings.openBranch,
          icon: Icons.add_business_rounded,
          expand: true,
          loading: _saving,
          onPressed: _submit,
        ),
      ),
    );
  }
}
