import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/paged.dart';
import '../../../account/domain/entities/account.dart';
import '../../../account/domain/repositories/account_repository.dart';
import '../../../account/data/models/account_models.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../report/domain/entities/report_entities.dart';
import '../../../report/domain/entities/report_range.dart';
import '../../../report/domain/repositories/report_repository.dart';
import '../../data/manager_registry.dart';
import '../../data/models/hotel_chain_models.dart';
import '../entities/hotel_chain.dart';
import '../repositories/hotel_chain_repository.dart';

/// Chuỗi mới luôn chờ quản trị viên duyệt, như lúc đăng ký chủ khách sạn.
@injectable
class CreateHotelChain {
  const CreateHotelChain(this._repository);

  final HotelChainRepository _repository;

  Future<HotelChain> call({
    required HotelChainProfile profile,
    required String ownerAccountId,
  }) =>
      _repository.create(
        HotelChainRequest.fromProfile(profile, accountId: ownerAccountId),
      );
}

@injectable
class UpdateHotelChain {
  const UpdateHotelChain(this._repository);

  final HotelChainRepository _repository;

  Future<HotelChain> call(HotelChain chain, {required String name, required String description}) =>
      _repository.update(
        chain.id,
        HotelChainRequest(
          name: name.trim(),
          description: description.trim(),
          pathImage: chain.pathImage,
        ),
      );
}

@injectable
class DeleteHotelChain {
  const DeleteHotelChain(this._repository);

  final HotelChainRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}

@injectable
class GetHotelChainDetail {
  const GetHotelChainDetail(this._repository);

  final HotelChainRepository _repository;

  Future<HotelChainDetail> call(int id) => _repository.getDetail(id);
}

@injectable
class GetHotelChainsPage {
  const GetHotelChainsPage(this._repository);

  final HotelChainRepository _repository;

  Future<Paged<HotelChain>> call({required int page, required int size}) =>
      _repository.getAll(page: page, size: size);
}

class ChainOverview extends Equatable {
  const ChainOverview({
    required this.detail,
    required this.last5Months,
    this.occupancy,
  });

  final HotelChainDetail detail;
  final List<RevenueByMonth> last5Months;
  final OccupancySummary? occupancy;

  @override
  List<Object?> get props => [detail, last5Months, occupancy];
}

@injectable
class LoadChainOverview {
  const LoadChainOverview(this._chains, this._reports);

  final HotelChainRepository _chains;
  final ReportRepository _reports;

  Future<ChainOverview> call(int chainId) async {
    final scope = ChainReportScope(chainId);
    final detail = _chains.getDetail(chainId);
    final last5 = _reports.revenueLast5Months(scope);
    OccupancySummary? occupancy;
    try {
      occupancy = await _reports.occupancy(
        scope,
        ReportRange.preset(ReportPreset.thisMonth),
      );
    } catch (_) {
      occupancy = null;
    }
    return ChainOverview(
      detail: await detail,
      last5Months: [...await last5]..sort((a, b) => a.monthIndex.compareTo(b.monthIndex)),
      occupancy: occupancy,
    );
  }
}

class ManagerSummary extends Equatable {
  const ManagerSummary({required this.account, required this.branches});

  final Account account;
  final List<Hotel> branches;

  @override
  List<Object?> get props => [account, branches];
}

/// Quản lý của chuỗi = tài khoản đang giữ cơ sở + tài khoản chủ vừa tạo trên máy.
@injectable
class GetChainManagers {
  const GetChainManagers(this._accounts, this._registry);

  final AccountRepository _accounts;
  final ManagerRegistry _registry;

  Future<List<ManagerSummary>> call(
    HotelChainDetail detail, {
    required String ownerUsername,
  }) async {
    final ids = {...detail.managerAccountIds, ..._registry.read(ownerUsername)};
    final summaries = await Future.wait(
      ids.map((id) async {
        try {
          final account = await _accounts.getById(id);
          if (account.role != Role.hotelManager) return null;
          return ManagerSummary(
            account: account,
            branches: detail.hotels.where((h) => h.accountId == id).toList(),
          );
        } catch (_) {
          return null;
        }
      }),
    );
    return summaries.whereType<ManagerSummary>().toList()
      ..sort((a, b) => a.account.username.compareTo(b.account.username));
  }
}

@injectable
class CreateManagerAccount {
  const CreateManagerAccount(this._accounts, this._registry);

  final AccountRepository _accounts;
  final ManagerRegistry _registry;

  Future<Account> call({
    required String username,
    required String password,
    required String ownerUsername,
  }) async {
    final account = await _accounts.create(
      AccountCreateRequest(
        username: username.trim(),
        password: password,
        role: Role.hotelManager,
      ),
    );
    await _registry.add(ownerUsername, account.id);
    return account;
  }
}
