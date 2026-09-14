import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/bloc/paged_cubit.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/network/paged.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/enum_labels.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../account/domain/entities/account.dart';
import '../../account/domain/usecases/account_usecases.dart';
import '../../auth/presentation/session/session_cubit.dart';

@injectable
class AccountsCubit extends PagedCubit<Account> {
  AccountsCubit(this._getPage);

  final GetAccountsPage _getPage;

  @override
  Future<Paged<Account>> fetch({required int page, required int size}) =>
      _getPage(page: page, size: size);
}

/// Tab Tài khoản của quản trị viên.
@RoutePage()
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AccountsCubit>()..load(),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatefulWidget {
  const _AccountsView();

  @override
  State<_AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<_AccountsView> {
  final _search = TextEditingController();
  String _query = '';
  Role? _role;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Account account) {
    final query = _query.trim().toLowerCase();
    return (_role == null || account.role == _role) &&
        (query.isEmpty || account.username.toLowerCase().contains(query));
  }

  Future<void> _create() async {
    final created = await AppDialogs.sheet<bool>(
      context,
      title: ManagementStrings.createAccount,
      builder: (_) => const AccountFormSheet(),
    );
    if (created != true || !mounted) return;
    AppToast.success(context, ManagementStrings.accountSaved);
    await context.read<AccountsCubit>().load();
  }

  Future<void> _edit(Account account) async {
    final changed = await AppDialogs.sheet<bool>(
      context,
      title: ManagementStrings.editAccount,
      builder: (_) => AccountEditSheet(account: account),
    );
    if (changed == true && mounted) await context.read<AccountsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, PagedState<Account>>(
      builder: (context, state) {
        final cubit = context.read<AccountsCubit>();
        return AppPage(
          title: ManagementStrings.accountsTitle,
          subtitle: state.status == ViewStatus.success ? AppStrings.itemsCount(state.total) : null,
          actions: [
            IconButton(
              tooltip: AppStrings.refresh,
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text(ManagementStrings.createAccount),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: AppSearchField(
                  controller: _search,
                  hint: ManagementStrings.searchUsername,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              ChoiceChipBar<Role?>(
                options: const <Role?>[null, ...Role.values],
                selected: _role,
                labelOf: (role) => role?.label ?? AppStrings.all,
                onSelected: (role) => setState(() => _role = role),
              ),
              const Gap(AppSpacing.xs),
              Expanded(
                child: PagedListView<Account>(
                  state: state,
                  onRefresh: cubit.load,
                  onLoadMore: cubit.loadMore,
                  filter: _matches,
                  empty: const AppEmptyView(
                    icon: Icons.manage_accounts_outlined,
                    title: ManagementStrings.accountsEmpty,
                  ),
                  itemBuilder: (context, account) => AppCard(
                    onTap: () => _edit(account),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: AccountSummaryRow(account: account),
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

/// Một dòng tài khoản: tên đăng nhập, ngày tạo, vai trò, trạng thái khoá.
class AccountSummaryRow extends StatelessWidget {
  const AccountSummaryRow({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AppAvatar(name: account.username, size: 40, tone: account.role.tone),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.username,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  account.createdAt == null
                      ? account.role.label
                      : ManagementStrings.createdOn(Fmt.date(account.createdAt)),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge.role(account.role, dense: true),
              if (!account.active) ...[
                const Gap(4),
                const SoftTag(label: ManagementStrings.accountLocked, tone: StatusTone.danger),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Tạo tài khoản quản trị / chủ khách sạn / quản lý. Trả `true` khi đã tạo.
class AccountFormSheet extends StatefulWidget {
  const AccountFormSheet({super.key, this.initialRole = Role.hotelOwner});

  final Role initialRole;

  @override
  State<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<AccountFormSheet> {
  static const _roles = [Role.hotelOwner, Role.hotelManager, Role.admin];

  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  late Role _role = widget.initialRole;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<CreateAccount>()(
        username: _username.text.trim(),
        password: _password.text,
        role: _role,
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
            validator: Validators.password,
          ),
          const Gap(AppSpacing.sm),
          AppDropdownField<Role>(
            label: ManagementStrings.role,
            prefixIcon: Icons.shield_outlined,
            items: _roles,
            value: _role,
            itemLabel: (role) => role.label,
            onChanged: (role) => setState(() => _role = role ?? _role),
          ),
          const Gap(AppSpacing.xs),
          const IconText(
            icon: Icons.info_outline_rounded,
            text: ManagementStrings.staffAccountNote,
            maxLines: 2,
          ),
          if (_error != null) ...[
            const Gap(AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.lg),
          AppButton(
            label: ManagementStrings.createAccount,
            expand: true,
            loading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Đổi vai trò, khoá/mở hoặc xoá một tài khoản. Trả `true` khi có thay đổi.
class AccountEditSheet extends StatefulWidget {
  const AccountEditSheet({super.key, required this.account});

  final Account account;

  @override
  State<AccountEditSheet> createState() => _AccountEditSheetState();
}

class _AccountEditSheetState extends State<AccountEditSheet> {
  late Role _role = widget.account.role;
  late bool _active = widget.account.active;
  bool _busy = false;
  String? _error;

  /// Nhân viên và khách hàng có hồ sơ riêng — không đổi vai trò tại đây.
  bool get _roleLocked =>
      widget.account.role == Role.staff || widget.account.role == Role.customer;

  List<Role> get _roles =>
      {Role.admin, Role.hotelOwner, Role.hotelManager, widget.account.role}.toList();

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final account = widget.account;
    final result = await runAction(
      () => getIt<UpdateAccount>()(
        account.id,
        role: _role == account.role ? null : _role,
        active: _active == account.active ? null : _active,
      ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      AppToast.success(context, ManagementStrings.accountSaved);
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = result.error;
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage(widget.account.username),
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await runAction(() => getIt<DeleteAccount>()(widget.account.id));
    if (!mounted) return;
    if (result.isSuccess) {
      AppToast.success(context, ManagementStrings.accountDeleted);
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = context.select(
      (SessionCubit cubit) => cubit.state.session?.username,
    );
    final isSelf = currentUsername == widget.account.username;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountSummaryRow(account: widget.account),
        const Gap(AppSpacing.sm),
        if (isSelf)
          const IconText(
            icon: Icons.info_outline_rounded,
            text: ManagementStrings.cannotEditSelf,
            maxLines: 3,
          )
        else ...[
          AppDropdownField<Role>(
            label: ManagementStrings.role,
            prefixIcon: Icons.shield_outlined,
            items: _roles,
            value: _role,
            enabled: !_roleLocked,
            itemLabel: (role) => role.label,
            onChanged: (role) => setState(() => _role = role ?? _role),
          ),
          const Gap(AppSpacing.xs),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            title: Text(ManagementStrings.accountActive, style: AppTextStyles.bodyMedium),
            subtitle: Text(ManagementStrings.accountStatusNote, style: AppTextStyles.caption),
          ),
          if (_error != null) ...[
            const Gap(AppSpacing.xs),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.dangerOutline,
                  label: AppStrings.delete,
                  icon: Icons.delete_outline_rounded,
                  onPressed: _busy ? null : _delete,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: AppStrings.save,
                  loading: _busy,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
