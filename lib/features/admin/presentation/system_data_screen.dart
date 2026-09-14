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
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/network/paged.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/text/workspace_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../customer/domain/entities/customer.dart';
import '../../customer/domain/usecases/customer_usecases.dart';
import '../../customer/presentation/branch/branch_customers_screen.dart';
import '../../employee/domain/entities/employee.dart';
import '../../employee/domain/usecases/employee_usecases.dart';
import '../../hotel/domain/entities/hotel.dart';
import '../../hotel/domain/usecases/hotel_usecases.dart';
import '../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../hotel_chain/domain/usecases/hotel_chain_usecases.dart';

@injectable
class ChainsPageCubit extends PagedCubit<HotelChain> {
  ChainsPageCubit(this._getPage);

  final GetHotelChainsPage _getPage;

  @override
  Future<Paged<HotelChain>> fetch({required int page, required int size}) =>
      _getPage(page: page, size: size);
}

@injectable
class BranchesPageCubit extends PagedCubit<Hotel> {
  BranchesPageCubit(this._getPage);

  final GetHotelsPage _getPage;

  @override
  Future<Paged<Hotel>> fetch({required int page, required int size}) => _getPage(page);
}

@injectable
class CustomersPageCubit extends PagedCubit<Customer> {
  CustomersPageCubit(this._getPage);

  final GetCustomersPage _getPage;

  @override
  Future<Paged<Customer>> fetch({required int page, required int size}) =>
      _getPage(page: page, size: size);
}

@injectable
class EmployeesPageCubit extends PagedCubit<Employee> {
  EmployeesPageCubit(this._getPage);

  final GetEmployeesPage _getPage;

  @override
  Future<Paged<Employee>> fetch({required int page, required int size}) =>
      _getPage(page: page, size: size);
}

enum _Dataset { chains, branches, customers, employees }

/// Tab Hệ thống: tra cứu toàn bộ chuỗi, cơ sở, khách hàng, nhân viên.
@RoutePage()
class SystemDataScreen extends StatelessWidget {
  const SystemDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ChainsPageCubit>()..load()),
        BlocProvider(create: (_) => getIt<BranchesPageCubit>()),
        BlocProvider(create: (_) => getIt<CustomersPageCubit>()),
        BlocProvider(create: (_) => getIt<EmployeesPageCubit>()),
      ],
      child: const _SystemDataView(),
    );
  }
}

class _SystemDataView extends StatefulWidget {
  const _SystemDataView();

  @override
  State<_SystemDataView> createState() => _SystemDataViewState();
}

class _SystemDataViewState extends State<_SystemDataView> {
  _Dataset _dataset = _Dataset.chains;

  static String _label(_Dataset dataset) => switch (dataset) {
        _Dataset.chains => ManagementStrings.chains,
        _Dataset.branches => ManagementStrings.branches,
        _Dataset.customers => ManagementStrings.customers,
        _Dataset.employees => ManagementStrings.employees,
      };

  static void _ensureLoaded(PagedCubit<Object?> cubit) {
    if (cubit.state.status == ViewStatus.initial) cubit.load();
  }

  void _select(_Dataset dataset) {
    setState(() => _dataset = dataset);
    switch (dataset) {
      case _Dataset.chains:
        _ensureLoaded(context.read<ChainsPageCubit>());
      case _Dataset.branches:
        _ensureLoaded(context.read<BranchesPageCubit>());
      case _Dataset.customers:
        _ensureLoaded(context.read<CustomersPageCubit>());
      case _Dataset.employees:
        _ensureLoaded(context.read<EmployeesPageCubit>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: ManagementStrings.systemTitle,
      body: Column(
        children: [
          const Gap(AppSpacing.xs),
          ChoiceChipBar<_Dataset>(
            options: _Dataset.values,
            selected: _dataset,
            labelOf: _label,
            onSelected: _select,
          ),
          const Gap(AppSpacing.xs),
          Expanded(
            child: switch (_dataset) {
              _Dataset.chains => BlocBuilder<ChainsPageCubit, PagedState<HotelChain>>(
                  builder: (context, state) {
                    final cubit = context.read<ChainsPageCubit>();
                    return PagedListView<HotelChain>(
                      state: state,
                      onRefresh: cubit.load,
                      onLoadMore: cubit.loadMore,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                      empty: const AppEmptyView(
                        icon: Icons.apartment_rounded,
                        title: AppStrings.emptyTitle,
                      ),
                      itemBuilder: (context, chain) => _ChainTile(chain: chain),
                    );
                  },
                ),
              _Dataset.branches => BlocBuilder<BranchesPageCubit, PagedState<Hotel>>(
                  builder: (context, state) {
                    final cubit = context.read<BranchesPageCubit>();
                    return PagedListView<Hotel>(
                      state: state,
                      onRefresh: cubit.load,
                      onLoadMore: cubit.loadMore,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                      empty: const AppEmptyView(
                        icon: Icons.storefront_outlined,
                        title: AppStrings.emptyTitle,
                      ),
                      itemBuilder: (context, hotel) => _BranchTile(
                        hotel: hotel,
                        onTap: () =>
                            context.rootRouter.push(WorkspaceShellRoute(hotelId: hotel.id)),
                      ),
                    );
                  },
                ),
              _Dataset.customers => BlocBuilder<CustomersPageCubit, PagedState<Customer>>(
                  builder: (context, state) {
                    final cubit = context.read<CustomersPageCubit>();
                    return PagedListView<Customer>(
                      state: state,
                      onRefresh: cubit.load,
                      onLoadMore: cubit.loadMore,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                      empty: const AppEmptyView(
                        icon: Icons.groups_outlined,
                        title: AppStrings.emptyTitle,
                      ),
                      itemBuilder: (context, customer) => CustomerTile(customer: customer),
                    );
                  },
                ),
              _Dataset.employees => BlocBuilder<EmployeesPageCubit, PagedState<Employee>>(
                  builder: (context, state) {
                    final cubit = context.read<EmployeesPageCubit>();
                    return PagedListView<Employee>(
                      state: state,
                      onRefresh: cubit.load,
                      onLoadMore: cubit.loadMore,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
                      empty: const AppEmptyView(
                        icon: Icons.badge_outlined,
                        title: AppStrings.emptyTitle,
                      ),
                      itemBuilder: (context, employee) => _EmployeeTile(employee: employee),
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _ChainTile extends StatelessWidget {
  const _ChainTile({required this.chain});

  final HotelChain chain;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(
            name: chain.name,
            imagePath: chain.pathImage,
            size: 42,
            tone: StatusTone.warning,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chain.name,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (chain.description.isNotEmpty)
                  Text(
                    chain.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({required this.hotel, required this.onTap});

  final Hotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppNetworkImage(
            path: hotel.pathImage,
            width: 56,
            height: 56,
            borderRadius: AppRadius.smAll,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                IconText(icon: Icons.location_on_outlined, text: hotel.address),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          StatusBadge(
            dense: true,
            label: hotel.active ? WorkspaceStrings.branchActive : WorkspaceStrings.branchInactive,
            tone: hotel.active ? StatusTone.success : StatusTone.neutral,
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkTertiary),
        ],
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final details = [employee.positionName, employee.hotelName ?? '']
        .where((part) => part.isNotEmpty)
        .join(' · ');
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(name: employee.fullName, imagePath: employee.pathImage, size: 42),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            Fmt.money(employee.salary),
            style: AppTextStyles.tabular.weight(FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
