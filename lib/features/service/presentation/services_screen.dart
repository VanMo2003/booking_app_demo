import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../data/models/hotel_service_models.dart';
import '../domain/entities/hotel_service.dart';
import '../domain/usecases/hotel_service_usecases.dart';

@injectable
class ServicesCubit extends LoadCubit<List<HotelService>> {
  ServicesCubit(this._getServices);

  final GetBranchServices _getServices;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() => _getServices(_hotelId));
}

/// Dịch vụ tính thêm tiền của cơ sở. Quản trị viên chỉ xem.
@RoutePage()
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServicesCubit>()..start(hotelId),
      child: _ServicesView(hotelId: hotelId),
    );
  }
}

class _ServicesView extends StatelessWidget {
  const _ServicesView({required this.hotelId});

  final int hotelId;

  Future<void> _openForm(BuildContext context, {HotelService? service}) async {
    final saved = await AppDialogs.sheet<bool>(
      context,
      title: service == null ? WorkspaceStrings.addService : WorkspaceStrings.editService,
      builder: (_) => _ServiceForm(hotelId: hotelId, service: service),
    );
    if (saved != true || !context.mounted) return;
    AppToast.success(context, WorkspaceStrings.serviceSaved);
    await context.read<ServicesCubit>().load();
  }

  Future<void> _delete(BuildContext context, HotelService service) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(service.name),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteService>()(service.id)),
      successMessage: WorkspaceStrings.serviceDeleted,
    );
    if (result.isSuccess && context.mounted) await context.read<ServicesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select((SessionCubit cubit) => cubit.state.role);
    final canEdit = role?.canEditBranchContent ?? false;
    final canDelete = canEdit && (role?.isManagerOrAbove ?? false);
    return BlocBuilder<ServicesCubit, LoadState<List<HotelService>>>(
      builder: (context, state) {
        final cubit = context.read<ServicesCubit>();
        return AppPage(
          title: WorkspaceStrings.servicesTitle,
          subtitle: state.hasData ? AppStrings.itemsCount(state.data!.length) : null,
          floatingActionButton: !canEdit || (state.data?.isEmpty ?? true)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(WorkspaceStrings.addService),
                ),
          body: LoadStateView<List<HotelService>>(
            state: state,
            onRetry: cubit.load,
            isEmpty: (data) => data.isEmpty,
            empty: AppEmptyView(
              icon: Icons.room_service_outlined,
              title: WorkspaceStrings.servicesEmpty,
              addLabel: WorkspaceStrings.addService,
              onAdd: canEdit ? () => _openForm(context) : null,
            ),
            builder: (context, services) => RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, AppSpacing.bottomBarClearance),
                children: [
                  if (canEdit)
                    const IconText(
                      icon: Icons.info_outline_rounded,
                      text: WorkspaceStrings.servicePriceNote,
                      maxLines: 2,
                    )
                  else
                    const NoticeBanner(
                      text: WorkspaceStrings.readOnlyNotice,
                      icon: Icons.visibility_outlined,
                    ),
                  const Gap(AppSpacing.sm),
                  for (final service in services) ...[
                    AppCard(
                      onTap: canEdit ? () => _openForm(context, service: service) : null,
                      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: const Icon(Icons.room_service_outlined, color: AppColors.primary),
                          ),
                          const Gap(AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.name, style: AppTextStyles.bodyStrong),
                                if (service.description.isNotEmpty)
                                  Text(
                                    service.description,
                                    style: AppTextStyles.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(Fmt.money(service.unitPrice), style: AppTextStyles.money),
                          if (canDelete)
                            IconButton(
                              tooltip: AppStrings.delete,
                              onPressed: () => _delete(context, service),
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.inkTertiary),
                            )
                          else
                            const Gap(AppSpacing.sm),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceForm extends StatefulWidget {
  const _ServiceForm({required this.hotelId, this.service});

  final int hotelId;
  final HotelService? service;

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.service?.name);
  late final _price = TextEditingController(
    text: ThousandsInputFormatter.format(widget.service?.unitPrice),
  );
  late final _description = TextEditingController(text: widget.service?.description);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final service = widget.service;
    final result = await runAction(
      () => getIt<SaveService>()(
        ServiceRequest(
          name: _name.text.trim(),
          unitPrice: Validators.parseMoney(_price.text) ?? 0,
          description: _description.text.trim(),
          hotelId: service == null ? widget.hotelId : null,
        ),
        id: service?.id,
      ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            label: WorkspaceStrings.serviceName,
            prefixIcon: Icons.room_service_outlined,
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required(),
          ),
          const Gap(AppSpacing.sm),
          AppMoneyField(
            controller: _price,
            label: WorkspaceStrings.unitPrice,
            validator: Validators.money,
          ),
          const Gap(AppSpacing.sm),
          AppTextField(
            controller: _description,
            label: WorkspaceStrings.description,
            minLines: 2,
            maxLines: 4,
          ),
          if (_error != null) ...[
            const Gap(AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.lg),
          AppButton(label: AppStrings.save, expand: true, loading: _saving, onPressed: _submit),
        ],
      ),
    );
  }
}
