import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/session_events.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/auth_usecases.dart';

enum SessionStatus { unknown, guest, authenticated }

class SessionState extends Equatable {
  const SessionState._(this.status, this.session);

  const SessionState.unknown() : this._(SessionStatus.unknown, null);

  const SessionState.guest() : this._(SessionStatus.guest, null);

  const SessionState.authenticated(Session session)
      : this._(SessionStatus.authenticated, session);

  final SessionStatus status;
  final Session? session;

  bool get isGuest => session == null;
  Role? get role => session?.role;

  @override
  List<Object?> get props => [status, session];
}

/// Nguồn sự thật duy nhất về người đang dùng app, dùng chung toàn ứng dụng.
@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(
    this._restoreSession,
    this._logout,
    this._persistSession,
    SessionEvents events,
  ) : super(const SessionState.unknown()) {
    _expiredSubscription = events.onExpired.listen((_) => _handleExpired());
  }

  final RestoreSession _restoreSession;
  final Logout _logout;
  final PersistSession _persistSession;
  late final StreamSubscription<void> _expiredSubscription;
  bool _expiredNotice = false;

  Session? get session => state.session;

  Future<Session?> restore() async {
    final session = await _restoreSession();
    emit(
      session == null
          ? const SessionState.guest()
          : SessionState.authenticated(session),
    );
    return session;
  }

  void signedIn(Session session) => emit(SessionState.authenticated(session));

  /// Cập nhật hồ sơ phiên (tạo hồ sơ khách, dò được cơ sở, tạo chuỗi…).
  Future<void> update(Session session) async {
    await _persistSession(session);
    emit(SessionState.authenticated(session));
  }

  Future<void> logout() async {
    await _logout();
    emit(const SessionState.guest());
  }

  /// `true` một lần duy nhất sau khi phiên bị hết hạn phía máy chủ.
  bool consumeExpiredNotice() {
    final value = _expiredNotice;
    _expiredNotice = false;
    return value;
  }

  void _handleExpired() {
    if (state.session == null) return;
    _expiredNotice = true;
    emit(const SessionState.guest());
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
