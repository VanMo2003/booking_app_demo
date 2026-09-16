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
import '../../../core/text/enum_labels.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/utils/formatters.dart';
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

/// Tab Tài khoản của quản trị viên: tra cứu và khoá/mở tài khoản. Quản trị viên
/// không tạo tài khoản — chủ khách sạn tự đăng ký, quản lý do chủ khách sạn tạo.
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

  Future<void> _review(Account account) async {
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                  empty: const AppEmptyView(
                    icon: Icons.manage_accounts_outlined,
                    title: ManagementStrings.accountsEmpty,
                  ),
                  itemBuilder: (context, account) => AppCard(
                    onTap: () => _review(account),
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

/// Khoá hoặc mở một tài khoản. Trả `true` khi có thay đổi.
class AccountEditSheet extends StatefulWidget {
  const AccountEditSheet({super.key, required this.account});

  final Account account;

  @override
  State<AccountEditSheet> createState() => _AccountEditSheetState();
}

class _AccountEditSheetState extends State<AccountEditSheet> {
  late bool _active = widget.account.active;
  bool _busy = false;
  String? _error;

  Future<void> _save() async {
    if (_active == widget.account.active) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<SetAccountActive>()(widget.account.id, active: _active),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: _busy ? null : (value) => setState(() => _active = value),
            title: Text(ManagementStrings.accountActive, style: AppTextStyles.bodyMedium),
            subtitle: Text(ManagementStrings.accountStatusNote, style: AppTextStyles.caption),
          ),
          if (_error != null) ...[
            const Gap(AppSpacing.xs),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.sm),
          const NoticeBanner(text: ManagementStrings.accountsReviewNote),
          const Gap(AppSpacing.md),
          AppButton(
            label: AppStrings.save,
            expand: true,
            loading: _busy,
            onPressed: _save,
          ),
        ],
      ],
    );
  }
}
