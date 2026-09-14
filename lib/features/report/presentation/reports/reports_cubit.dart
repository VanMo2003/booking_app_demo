import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/network/app_exception.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel_chain/domain/usecases/hotel_chain_usecases.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/report_views.dart';
import '../../domain/usecases/report_usecases.dart';

enum ReportTab { revenue, occupancy, breakdown, people }

class ReportsState extends Equatable {
  const ReportsState({
    required this.range,
    this.preset = ReportPreset.thisMonth,
    this.granularity = RevenueGranularity.day,
    this.revenue = const LoadState(),
    this.occupancy = const LoadState(),
    this.breakdown = const LoadState(),
    this.people = const LoadState(),
    this.comparison = const LoadState(),
  });

  final ReportPreset preset;
  final ReportRange range;
  final RevenueGranularity granularity;
  final LoadState<RevenueReport> revenue;
  final LoadState<OccupancyReport> occupancy;
  final LoadState<BreakdownReport> breakdown;
  final LoadState<PeopleReport> people;

  /// So sánh doanh thu giữa các cơ sở — chỉ có ở báo cáo chuỗi.
  final LoadState<List<BranchRevenue>> comparison;

  ReportsState copyWith({
    RevenueGranularity? granularity,
    LoadState<RevenueReport>? revenue,
    LoadState<OccupancyReport>? occupancy,
    LoadState<BreakdownReport>? breakdown,
    LoadState<PeopleReport>? people,
    LoadState<List<BranchRevenue>>? comparison,
  }) =>
      ReportsState(
        range: range,
        preset: preset,
        granularity: granularity ?? this.granularity,
        revenue: revenue ?? this.revenue,
        occupancy: occupancy ?? this.occupancy,
        breakdown: breakdown ?? this.breakdown,
        people: people ?? this.people,
        comparison: comparison ?? this.comparison,
      );

  @override
  List<Object?> get props =>
      [preset, range, granularity, revenue, occupancy, breakdown, people, comparison];
}

/// Báo cáo dùng chung cho cơ sở và chuỗi. Mỗi tab chỉ tải khi được mở;
/// đổi khoảng thời gian thì tải lại tab đang xem, kết quả cũ về muộn bị bỏ qua.
@injectable
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(
    this._revenue,
    this._occupancy,
    this._breakdown,
    this._people,
    this._export,
    this._comparison,
    this._chainDetail,
  ) : super(ReportsState(range: ReportRange.preset(ReportPreset.thisMonth)));

  final LoadRevenueReport _revenue;
  final LoadOccupancyReport _occupancy;
  final LoadBreakdownReport _breakdown;
  final LoadPeopleReport _people;
  final ExportReport _export;
  final LoadBranchComparison _comparison;
  final GetHotelChainDetail _chainDetail;

  late ReportScope _scope;
  final Set<ReportTab> _loaded = {};
  ReportTab _current = ReportTab.revenue;
  List<Hotel>? _chainHotels;

  ReportScope get scope => _scope;

  void start(ReportScope scope) {
    _scope = scope;
    loadTab(ReportTab.revenue);
  }

  Future<void> loadTab(ReportTab tab, {bool force = false}) async {
    _current = tab;
    final isNew = _loaded.add(tab);
    if (!isNew && !force) return;
    switch (tab) {
      case ReportTab.revenue:
        await Future.wait([_loadRevenue(), _loadComparison()]);
      case ReportTab.occupancy:
        await _loadOccupancy();
      case ReportTab.breakdown:
        await _loadBreakdown();
      case ReportTab.people:
        await _loadPeople();
    }
  }

  Future<void> refresh() {
    _loaded.clear();
    return loadTab(_current, force: true);
  }

  void setPreset(ReportPreset preset) {
    if (preset == ReportPreset.custom) return;
    _applyRange(ReportRange.preset(preset), preset);
  }

  void setCustomRange(DateTimeRange range) =>
      _applyRange(ReportRange(range.start, range.end), ReportPreset.custom);

  void setGranularity(RevenueGranularity granularity) {
    if (granularity == state.granularity) return;
    emit(state.copyWith(granularity: granularity));
    _loadRevenue();
  }

  Future<ActionResult<ReportFile>> export() => runAction(() => _export(_scope, state.range));

  void _applyRange(ReportRange range, ReportPreset preset) {
    final granularity = switch (state.granularity) {
      RevenueGranularity.year => RevenueGranularity.year,
      _ when preset == ReportPreset.thisYear => RevenueGranularity.month,
      _ when range.days > 62 => RevenueGranularity.week,
      _ => RevenueGranularity.day,
    };
    emit(ReportsState(range: range, preset: preset, granularity: granularity));
    _loaded.clear();
    loadTab(_current);
  }

  bool _isCurrent(ReportRange range) => !isClosed && state.range == range;

  String _message(Object error) => AppException.from(error).message;

  Future<void> _loadRevenue() async {
    final range = state.range;
    final granularity = state.granularity;
    emit(state.copyWith(revenue: state.revenue.toLoading()));
    try {
      final report = await _revenue(_scope, range, granularity);
      if (_isCurrent(range) && state.granularity == granularity) {
        emit(state.copyWith(revenue: state.revenue.toSuccess(report)));
      }
    } catch (error) {
      if (_isCurrent(range)) {
        emit(state.copyWith(revenue: state.revenue.toFailure(_message(error))));
      }
    }
  }

  Future<void> _loadComparison() async {
    final scope = _scope;
    if (scope is! ChainReportScope) return;
    final range = state.range;
    emit(state.copyWith(comparison: state.comparison.toLoading()));
    try {
      final hotels = _chainHotels ??= (await _chainDetail(scope.hotelChainId)).hotels;
      final rows = await _comparison(hotels, range.to.year);
      if (_isCurrent(range)) {
        emit(state.copyWith(comparison: state.comparison.toSuccess(rows)));
      }
    } catch (error) {
      if (_isCurrent(range)) {
        emit(state.copyWith(comparison: state.comparison.toFailure(_message(error))));
      }
    }
  }

  Future<void> _loadOccupancy() async {
    final range = state.range;
    emit(state.copyWith(occupancy: state.occupancy.toLoading()));
    try {
      final report = await _occupancy(_scope, range);
      if (_isCurrent(range)) emit(state.copyWith(occupancy: state.occupancy.toSuccess(report)));
    } catch (error) {
      if (_isCurrent(range)) {
        emit(state.copyWith(occupancy: state.occupancy.toFailure(_message(error))));
      }
    }
  }

  Future<void> _loadBreakdown() async {
    final range = state.range;
    emit(state.copyWith(breakdown: state.breakdown.toLoading()));
    try {
      final report = await _breakdown(_scope, range);
      if (_isCurrent(range)) emit(state.copyWith(breakdown: state.breakdown.toSuccess(report)));
    } catch (error) {
      if (_isCurrent(range)) {
        emit(state.copyWith(breakdown: state.breakdown.toFailure(_message(error))));
      }
    }
  }

  Future<void> _loadPeople() async {
    final range = state.range;
    emit(state.copyWith(people: state.people.toLoading()));
    try {
      final report = await _people(_scope, range);
      if (_isCurrent(range)) emit(state.copyWith(people: state.people.toSuccess(report)));
    } catch (error) {
      if (_isCurrent(range)) {
        emit(state.copyWith(people: state.people.toFailure(_message(error))));
      }
    }
  }
}
