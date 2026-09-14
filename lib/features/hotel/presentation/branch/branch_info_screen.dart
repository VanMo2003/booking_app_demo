import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/hotel_models.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/hotel_usecases.dart';
import 'branch_cubit.dart';

/// Thông tin cơ sở: ảnh bìa, thư viện ảnh, liên hệ, trạng thái nhận khách.
/// Trả `true` khi đã lưu.
@RoutePage()
class BranchInfoScreen extends StatelessWidget {
  const BranchInfoScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchCubit>()..loadBranch(hotelId),
      child: BlocBuilder<BranchCubit, LoadState<HotelDetail>>(
        builder: (context, state) {
          final detail = state.data;
          if (detail == null) {
            return AppPage(
              title: WorkspaceStrings.branchInfoTitle,
              body: state.isFailure
                  ? AppErrorView(
                      message: state.error!,
                      onRetry: context.read<BranchCubit>().load,
                    )
                  : const AppLoadingView(),
            );
          }
          return _BranchInfoForm(detail: detail, refreshing: state.isLoading);
        },
      ),
    );
  }
}

class _BranchInfoForm extends StatefulWidget {
  const _BranchInfoForm({required this.detail, required this.refreshing});

  final HotelDetail detail;
  final bool refreshing;

  @override
  State<_BranchInfoForm> createState() => _BranchInfoFormState();
}

class _BranchInfoFormState extends State<_BranchInfoForm> {
  final _form = GlobalKey<FormState>();
  late final Hotel _initial = widget.detail.hotel;
  late final _name = TextEditingController(text: _initial.name);
  late final _address = TextEditingController(text: _initial.address);
  late final _phone = TextEditingController(text: _initial.phone);
  late final _description = TextEditingController(text: _initial.description);
  late String? _category = _initial.category.isEmpty ? null : _initial.category;
  late bool _active = _initial.active;
  bool _saving = false;
  bool _uploading = false;

  int get _hotelId => widget.detail.id;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _reload() => context.read<BranchCubit>().load();

  Future<void> _upload() async {
    final files = await ImagePickerHelper.pick();
    if (files.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    final result = await runAction(() => getIt<UploadBranchImages>()(_hotelId, files));
    if (!mounted) return;
    setState(() => _uploading = false);
    if (result.isSuccess) {
      AppToast.success(context, WorkspaceStrings.imagesUploaded);
      await _reload();
    } else {
      AppToast.error(context, result.error!);
    }
  }

  /// Chỉ đổi ảnh bìa, giữ nguyên các trường khác đang lưu trên máy chủ.
  Future<void> _setCover(String path) async {
    final hotel = widget.detail.hotel;
    if (path == hotel.pathImage) return;
    final confirmed = await AppDialogs.confirm(
      context,
      title: WorkspaceStrings.setCover,
      message: WorkspaceStrings.setCoverMessage,
      icon: Icons.star_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(
        () => getIt<UpdateBranch>()(
          _hotelId,
          HotelUpdateRequest.fromHotel(hotel, pathImage: path),
        ),
      ),
      successMessage: WorkspaceStrings.coverUpdated,
    );
    if (result.isSuccess && mounted) await _reload();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final result = await runAction(
      () => getIt<UpdateBranch>()(
        _hotelId,
        HotelUpdateRequest(
          name: _name.text.trim(),
          address: _address.text.trim(),
          phone: _phone.text.trim(),
          description: _description.text.trim(),
          category: _category ?? '',
          pathImage: widget.detail.hotel.pathImage,
          active: _active,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, WorkspaceStrings.branchSaved);
      context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    return AppPage(
      title: WorkspaceStrings.branchInfoTitle,
      subtitle: detail.hotel.name,
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            if (widget.refreshing) ...[
              const LinearProgressIndicator(minHeight: 2),
              const Gap(AppSpacing.xs),
            ],
            const SectionHeader(
              title: WorkspaceStrings.gallery,
              subtitle: WorkspaceStrings.imagesHint,
            ),
            const Gap(AppSpacing.sm),
            ImageGallery(
              networkPaths: detail.gallery,
              coverPath: detail.hotel.pathImage,
              onTapNetwork: _setCover,
              onAdd: _upload,
              busy: _uploading,
              addLabel: WorkspaceStrings.uploadImages,
            ),
            const Gap(AppSpacing.xl),
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
              onChanged: (value) => setState(() => _category = value),
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _description,
              label: WorkspaceStrings.description,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(WorkspaceStrings.acceptingGuests, style: AppTextStyles.bodyMedium),
                subtitle: Text(WorkspaceStrings.acceptingGuestsHint, style: AppTextStyles.caption),
              ),
            ),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: AppStrings.saveChanges,
          expand: true,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}
