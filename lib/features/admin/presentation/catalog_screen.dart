import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/utils/validators.dart';
import '../../catalog/domain/entities/catalog_item.dart';
import '../../catalog/domain/usecases/catalog_usecases.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.kind = CatalogKind.roomType,
    this.items = const LoadState(),
  });

  final CatalogKind kind;
  final LoadState<List<CatalogItem>> items;

  @override
  List<Object?> get props => [kind, items];
}

@injectable
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._getCatalog) : super(const CatalogState());

  final GetCatalog _getCatalog;

  Future<void> select(CatalogKind kind) {
    if (kind == state.kind && state.items.hasData) return Future.value();
    emit(CatalogState(kind: kind));
    return load();
  }

  Future<void> load() async {
    final kind = state.kind;
    emit(CatalogState(kind: kind, items: state.items.toLoading()));
    try {
      final items = await _getCatalog(kind);
      if (!isClosed && state.kind == kind) {
        emit(CatalogState(kind: kind, items: state.items.toSuccess(items)));
      }
    } catch (error) {
      if (!isClosed && state.kind == kind) {
        emit(CatalogState(
          kind: kind,
          items: state.items.toFailure(AppException.from(error).message),
        ));
      }
    }
  }
}

/// Tab Danh mục: loại phòng và chức vụ dùng chung toàn hệ thống.
@RoutePage()
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CatalogCubit>()..load(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  static String _kindLabel(CatalogKind kind) => switch (kind) {
        CatalogKind.roomType => ManagementStrings.roomTypes,
        CatalogKind.position => ManagementStrings.positions,
      };

  Future<void> _openForm(BuildContext context, CatalogKind kind, {CatalogItem? item}) async {
    final title = switch ((kind, item == null)) {
      (CatalogKind.roomType, true) => ManagementStrings.addRoomType,
      (CatalogKind.roomType, false) => ManagementStrings.editRoomType,
      (CatalogKind.position, true) => ManagementStrings.addPosition,
      (CatalogKind.position, false) => ManagementStrings.editPosition,
    };
    final saved = await AppDialogs.sheet<bool>(
      context,
      title: title,
      builder: (_) => _CatalogForm(kind: kind, item: item),
    );
    if (saved != true || !context.mounted) return;
    AppToast.success(context, AppStrings.saved);
    await context.read<CatalogCubit>().load();
  }

  Future<void> _delete(BuildContext context, CatalogKind kind, CatalogItem item) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(item.name),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteCatalogItem>()(kind, item.id)),
      successMessage: AppStrings.deleted,
    );
    if (result.isSuccess && context.mounted) await context.read<CatalogCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final cubit = context.read<CatalogCubit>();
        final kind = state.kind;
        return AppPage(
          title: ManagementStrings.catalogTitle,
          subtitle: state.items.hasData ? AppStrings.itemsCount(state.items.data!.length) : null,
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(context, kind),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              kind == CatalogKind.roomType
                  ? ManagementStrings.addRoomType
                  : ManagementStrings.addPosition,
            ),
          ),
          body: Column(
            children: [
              const Gap(AppSpacing.xs),
              ChoiceChipBar<CatalogKind>(
                options: CatalogKind.values,
                selected: kind,
                labelOf: _kindLabel,
                onSelected: cubit.select,
              ),
              const Gap(AppSpacing.xs),
              Expanded(
                child: LoadStateView<List<CatalogItem>>(
                  state: state.items,
                  onRetry: cubit.load,
                  isEmpty: (items) => items.isEmpty,
                  empty: const AppEmptyView(
                    icon: Icons.category_outlined,
                    title: ManagementStrings.catalogEmpty,
                  ),
                  builder: (context, items) => RefreshIndicator(
                    onRefresh: cubit.load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        AppSpacing.bottomBarClearance,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AppCard(
                          onTap: () => _openForm(context, kind, item: item),
                          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  kind == CatalogKind.roomType
                                      ? Icons.king_bed_outlined
                                      : Icons.work_outline_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Gap(AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: AppTextStyles.bodyStrong),
                                    if (item.description.isNotEmpty)
                                      Text(
                                        item.description,
                                        style: AppTextStyles.caption,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: AppStrings.delete,
                                onPressed: () => _delete(context, kind, item),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.inkTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogForm extends StatefulWidget {
  const _CatalogForm({required this.kind, this.item});

  final CatalogKind kind;
  final CatalogItem? item;

  @override
  State<_CatalogForm> createState() => _CatalogFormState();
}

class _CatalogFormState extends State<_CatalogForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.name);
  late final _description = TextEditingController(text: widget.item?.description);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<SaveCatalogItem>()(
        widget.kind,
        id: widget.item?.id,
        name: _name.text.trim(),
        description: _description.text.trim(),
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
            label: ManagementStrings.name,
            prefixIcon: widget.kind == CatalogKind.roomType
                ? Icons.king_bed_outlined
                : Icons.work_outline_rounded,
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required(),
          ),
          const Gap(AppSpacing.sm),
          AppTextField(
            controller: _description,
            label: ManagementStrings.description,
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
