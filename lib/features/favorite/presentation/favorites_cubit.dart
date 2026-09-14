import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../auth/presentation/session/session_cubit.dart';
import '../data/favorite_store.dart';
import '../domain/entities/favorite_hotel.dart';

/// Yêu thích của tài khoản đang đăng nhập; tự đổi khi đăng nhập/đăng xuất.
@lazySingleton
class FavoritesCubit extends Cubit<List<FavoriteHotel>> {
  FavoritesCubit(this._store, this._session) : super(const []) {
    _subscription = _session.stream.listen(_load);
    _load(_session.state);
  }

  final FavoriteStore _store;
  final SessionCubit _session;
  late final StreamSubscription<SessionState> _subscription;

  void _load(SessionState state) {
    final username = state.session?.username;
    emit(username == null ? const [] : _store.read(username));
  }

  bool contains(int hotelId) => state.any((hotel) => hotel.id == hotelId);

  /// Trả `true` nếu vừa thêm, `false` nếu vừa bỏ.
  Future<bool> toggle(FavoriteHotel hotel) async {
    final username = _session.state.session?.username;
    if (username == null) return false;
    final exists = contains(hotel.id);
    final next = exists
        ? state.where((item) => item.id != hotel.id).toList()
        : [hotel, ...state];
    emit(next);
    await _store.write(username, next);
    return !exists;
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
