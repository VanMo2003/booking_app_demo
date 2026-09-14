import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/color/status_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/workspace_strings.dart';
import '../../../../core/utils/text_search.dart';
import '../../../shell/presentation/workspace_scope.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_usecases.dart';

@injectable
class BranchCustomersCubit extends LoadCubit<List<Customer>> {
  BranchCustomersCubit(this._getCustomers);

  final GetBranchCustomers _getCustomers;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  @override
  Future<void> load() => guard(() async {
        final customers = await _getCustomers(_hotelId);
        return [...customers]..sort((a, b) => a.fullName.compareTo(b.fullName));
      });
}

/// Tab Khách của nhân viên.
@RoutePage()
class BranchCustomersScreen extends StatelessWidget {
  const BranchCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BranchCustomersView(
      hotelId: WorkspaceScope.of(context).hotelId,
      subtitle: context.branchName,
    );
  }
}

/// Danh bạ khách của cơ sở — quản lý mở từ menu Thêm.
@RoutePage()
class CustomerDirectoryScreen extends StatelessWidget {
  const CustomerDirectoryScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  Widget build(BuildContext context) => BranchCustomersView(hotelId: hotelId);
}

class BranchCustomersView extends StatelessWidget {
  const BranchCustomersView({super.key, required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(hotelId),
      create: (_) => getIt<BranchCustomersCubit>()..start(hotelId),
      child: _CustomersBody(hotelId: hotelId, subtitle: subtitle),
    );
  }
}

class _CustomersBody extends StatefulWidget {
  const _CustomersBody({required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  @override
  State<_CustomersBody> createState() => _CustomersBodyState();
}

class _CustomersBodyState extends State<_CustomersBody> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Customer customer) {
    final query = _query.trim();
    return query.isEmpty ||
        TextSearch.matches(customer.fullName, query) ||
        customer.phoneNumber.contains(query);
  }

  Future<void> _open(Customer customer) async {
    await context.rootRouter.push(
      CustomerDetailRoute(hotelId: widget.hotelId, customer: customer),
    );
    if (mounted) await context.read<BranchCustomersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchCustomersCubit, LoadState<List<Customer>>>(
      builder: (context, state) {
        final cubit = context.read<BranchCustomersCubit>();
        final customers = state.data ?? const <Customer>[];
        final visible = customers.where(_matches).toList();
        final subtitle = [
          if (widget.subtitle != null) widget.subtitle!,
          if (state.hasData) AppStrings.guests(customers.length),
        ].join(' · ');
        return AppPage(
          title: WorkspaceStrings.customersTitle,
          subtitle: subtitle.isEmpty ? null : subtitle,
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
                  hint: WorkspaceStrings.customersSearchHint,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              if (state.isLoading && state.hasData) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: LoadStateView<List<Customer>>(
                  state: state,
                  onRetry: cubit.load,
                  isEmpty: (data) => data.isEmpty,
                  empty: const AppEmptyView(
                    icon: Icons.groups_outlined,
                    title: WorkspaceStrings.customersEmpty,
                  ),
                  builder: (context, _) => RefreshIndicator(
                    onRefresh: cubit.load,
                    child: visible.isEmpty
                        ? ListView(
                            children: const [
                              Gap(AppSpacing.xxl),
                              AppEmptyView(
                                icon: Icons.search_off_rounded,
                                title: AppStrings.emptyTitle,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, AppSpacing.xl),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) => const Gap(AppSpacing.xs),
                            itemBuilder: (context, index) => CustomerTile(
                              customer: visible[index],
                              onTap: () => _open(visible[index]),
                            ),
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

class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, this.onTap});

  final Customer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final walkIn = customer.isWalkIn;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(
            name: customer.fullName,
            imagePath: customer.pathImage,
            size: 42,
            tone: walkIn ? StatusTone.neutral : StatusTone.brand,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                IconText(icon: Icons.phone_outlined, text: customer.phoneNumber),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          SoftTag(
            label: walkIn ? WorkspaceStrings.walkInBadge : WorkspaceStrings.accountBadge,
            tone: walkIn ? StatusTone.neutral : StatusTone.brand,
          ),
        ],
      ),
    );
  }
}
