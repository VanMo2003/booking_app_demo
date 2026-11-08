import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/discover_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../data/voucher_repository.dart';
import '../domain/entities/voucher.dart';
import 'voucher_widgets.dart';

/// Mã giảm giá của khách sạn, cho chủ chuỗi ([hotelChainId]) hoặc quản lý cơ sở ([hotelId]): tạo, sửa, tắt, xoá.
@RoutePage()
class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key, this.hotelChainId, this.hotelId, this.subtitle});

  final int? hotelChainId;
  final int? hotelId;
  final String? subtitle;

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final _repository = getIt<VoucherRepository>();
  LoadState<List<Voucher>> _state = const LoadState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _state.toLoading());
    try {
      final list = await _repository.list(hotelChainId: widget.hotelId == null ? widget.hotelChainId : null, hotelId: widget.hotelId);
      if (mounted) setState(() => _state = _state.toSuccess(list));
    } catch (error) {
      if (mounted) setState(() => _state = _state.toError(error));
    }
  }

  Future<void> _open([Voucher? voucher]) async {
    final saved = await context.router.push<bool>(
      VoucherFormRoute(voucher: voucher, hotelChainId: widget.hotelChainId, hotelId: widget.hotelId),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: VoucherStrings.manageTitle,
      subtitle: widget.subtitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(VoucherStrings.add),
      ),
      body: LoadStateView<List<Voucher>>(
        state: _state,
        onRetry: _load,
        isEmpty: (list) => list.isEmpty,
        empty: AppEmptyView(
          icon: Icons.local_offer_outlined,
          title: VoucherStrings.empty,
          message: VoucherStrings.emptyHint,
          onAdd: () => _open(),
          addLabel: VoucherStrings.add,
        ),
        builder: (context, list) => RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
            itemBuilder: (context, i) {
              final voucher = list[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VoucherTicket(voucher: voucher, onTap: () => _open(voucher)),
                  const Gap(4),
                  Row(
                    children: [
                      Text(VoucherStrings.used(voucher.usedCount, voucher.usageLimit), style: AppTextStyles.caption),
                      const Spacer(),
                      if (!voucher.active)
                        const StatusBadge(label: VoucherStrings.inactive, tone: StatusTone.neutral, dense: true)
                      else if (voucherExpired(voucher))
                        const StatusBadge(label: VoucherStrings.expired, tone: StatusTone.warning, dense: true),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tạo / sửa một mã giảm giá.
@RoutePage()
class VoucherFormScreen extends StatefulWidget {
  const VoucherFormScreen({super.key, this.voucher, this.hotelChainId, this.hotelId});

  final Voucher? voucher;
  final int? hotelChainId;
  final int? hotelId;

  @override
  State<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  final _form = GlobalKey<FormState>();
  late final Voucher? _old = widget.voucher;
  late final _code = TextEditingController(text: _old?.code ?? '');
  late final _title = TextEditingController(text: _old?.title ?? '');
  late final _description = TextEditingController(text: _old?.description ?? '');
  late final _value = TextEditingController(
    text: _old == null
        ? ''
        : (_old.discountType == DiscountType.percent
            ? _old.value.round().toString()
            : ThousandsInputFormatter.format(_old.value)),
  );
  late final _maxDiscount = TextEditingController(text: ThousandsInputFormatter.format(_old?.maxDiscount));
  late final _minOrder = TextEditingController(text: ThousandsInputFormatter.format(_old?.minOrderAmount));
  late final _usageLimit = TextEditingController(text: _old?.usageLimit?.toString() ?? '');
  late DiscountType _type = _old?.discountType ?? DiscountType.percent;
  late DateTime _startsAt = _old?.startsAt ?? DateOnly.today();
  late DateTime _endsAt = _old?.endsAt ?? DateOnly.today().add(const Duration(days: 30));
  late int _perCustomer = _old?.perCustomerLimit ?? 1;
  late bool _active = _old?.active ?? true;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_code, _title, _description, _value, _maxDiscount, _minOrder, _usageLimit]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _money(TextEditingController controller) => Validators.parseMoney(controller.text);

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_endsAt.isBefore(_startsAt)) {
      AppToast.error(context, VoucherStrings.datesOrder);
      return;
    }
    setState(() => _saving = true);
    final request = VoucherRequest(
      code: _old == null ? _code.text.trim() : null,
      title: _title.text.trim(),
      description: _description.text.trim(),
      discountType: _type,
      value: _type == DiscountType.percent ? double.tryParse(_value.text.trim()) : _money(_value),
      maxDiscount: _type == DiscountType.percent ? (_money(_maxDiscount) ?? 0) : 0,
      minOrderAmount: _money(_minOrder) ?? 0,
      startsAt: _startsAt,
      endsAt: _endsAt,
      usageLimit: int.tryParse(_usageLimit.text.trim()) ?? 0,
      perCustomerLimit: _perCustomer,
      active: _active,
      hotelChainId: _old == null && widget.hotelId == null ? widget.hotelChainId : null,
      hotelId: _old == null ? widget.hotelId : null,
    );
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<VoucherRepository>().save(request, id: _old?.id)),
      successMessage: VoucherStrings.saved,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) await context.router.maybePop(true);
  }

  Future<void> _delete() async {
    final ok = await AppDialogs.confirm(
      context,
      title: VoucherStrings.delete,
      message: VoucherStrings.deleteConfirm,
      confirmLabel: VoucherStrings.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<VoucherRepository>().delete(_old!.id)),
      successMessage: VoucherStrings.deleted,
    );
    if (result.isSuccess && mounted) await context.router.maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final percent = _type == DiscountType.percent;
    return AppPage(
      title: _old == null ? VoucherStrings.add : VoucherStrings.edit,
      actions: [
        if (_old != null)
          IconButton(tooltip: VoucherStrings.delete, icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
      ],
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            AppTextField(
              controller: _code,
              label: VoucherStrings.code,
              hint: VoucherStrings.codeHint,
              enabled: _old == null,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9_-]')), LengthLimitingTextInputFormatter(30)],
              validator: (v) => (v ?? '').trim().length < 3 ? 'Tối thiểu 3 ký tự' : null,
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _title,
              label: VoucherStrings.titleLabel,
              hint: VoucherStrings.titleHint,
              textCapitalization: TextCapitalization.sentences,
              validator: Validators.required(),
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _description,
              label: VoucherStrings.description,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(AppSpacing.md),
            const GroupLabel(VoucherStrings.type),
            SegmentedButton<DiscountType>(
              segments: const [
                ButtonSegment(value: DiscountType.percent, label: Text(VoucherStrings.percent)),
                ButtonSegment(value: DiscountType.amount, label: Text(VoucherStrings.amount)),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() {
                _type = set.first;
                _value.clear();
              }),
            ),
            const Gap(AppSpacing.sm),
            if (percent)
              AppTextField(
                controller: _value,
                label: VoucherStrings.valuePercent,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return VoucherStrings.needValue;
                  return n > 90 ? VoucherStrings.percentMax : null;
                },
              )
            else
              AppMoneyField(controller: _value, label: VoucherStrings.valueAmount, validator: Validators.money),
            if (percent) ...[
              const Gap(AppSpacing.sm),
              AppMoneyField(controller: _maxDiscount, label: VoucherStrings.maxDiscount, helper: VoucherStrings.optional),
            ],
            const Gap(AppSpacing.sm),
            AppMoneyField(controller: _minOrder, label: VoucherStrings.minOrder, helper: VoucherStrings.optional),
            const Gap(AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppDateField(
                    label: VoucherStrings.startsAt,
                    value: _startsAt,
                    onChanged: (d) => setState(() => _startsAt = d),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: AppDateField(
                    label: VoucherStrings.endsAt,
                    value: _endsAt,
                    firstDate: _startsAt,
                    onChanged: (d) => setState(() => _endsAt = d),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _usageLimit,
              label: VoucherStrings.usageLimit,
              helper: VoucherStrings.optional,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const Gap(AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Expanded(child: Text(VoucherStrings.perCustomer)),
                  IconButton(
                    onPressed: _perCustomer <= 1 ? null : () => setState(() => _perCustomer--),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text('$_perCustomer', style: AppTextStyles.subtitle),
                  IconButton(
                    onPressed: _perCustomer >= 20 ? null : () => setState(() => _perCustomer++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(VoucherStrings.active),
              value: _active,
              onChanged: (on) => setState(() => _active = on),
            ),
            Text(
              '${VoucherStrings.scope}: ${widget.hotelId != null || _old?.hotelId != null ? (_old?.hotelName ?? 'cơ sở này') : VoucherStrings.allBranches}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: _old == null ? VoucherStrings.add : 'Lưu',
          icon: Icons.check_rounded,
          expand: true,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}
