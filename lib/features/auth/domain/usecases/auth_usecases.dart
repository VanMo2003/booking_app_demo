import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../employee/domain/repositories/employee_repository.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel/domain/repositories/hotel_repository.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

@injectable
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<Session> call({required String username, required String password}) =>
      _repository.login(username: username.trim(), password: password);
}

/// Đăng ký rồi đăng nhập luôn để vào thẳng bước hoàn tất hồ sơ.
@injectable
class RegisterCustomer {
  const RegisterCustomer(this._repository);

  final AuthRepository _repository;

  Future<Session> call({required String username, required String password}) async {
    await _repository.registerCustomer(username: username.trim(), password: password);
    return _repository.login(username: username.trim(), password: password);
  }
}

@injectable
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

@injectable
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Session?> call() => _repository.restoreSession();
}

@injectable
class PersistSession {
  const PersistSession(this._repository);

  final AuthRepository _repository;

  Future<void> call(Session session) => _repository.saveSession(session);
}

/// Tìm cơ sở làm việc của nhân viên.
///
/// BE chưa trả `hotelId` trong hồ sơ nhân viên, nhưng `/employees/by-hotel`
/// chỉ cho nhân viên đọc đúng cơ sở của mình (cơ sở khác trả 403) — nên dò lần
/// lượt các cơ sở công khai và lấy cơ sở đầu tiên có nhân viên này.
@injectable
class ResolveStaffBranch {
  const ResolveStaffBranch(this._hotels, this._employees);

  final HotelRepository _hotels;
  final EmployeeRepository _employees;

  Future<int?> call(Session session) async {
    if (session.role != Role.staff) return null;
    final known = session.staffHotelId ?? session.employee?.hotelId;
    if (known != null) return known;
    final employeeId = session.employee?.id;
    if (employeeId == null) return null;

    for (final hotel in await _hotels.getAllHotels()) {
      try {
        final staff = await _employees.byHotel(hotel.id);
        if (staff.any((employee) => employee.id == employeeId)) return hotel.id;
      } catch (_) {
        // 403 với cơ sở không thuộc nhân viên — thử cơ sở tiếp theo.
      }
    }
    return null;
  }
}

/// Làm mới danh sách cơ sở của quản lý (lọc `/hotels` theo tài khoản quản lý).
@injectable
class RefreshManagerBranches {
  const RefreshManagerBranches(this._hotels);

  final HotelRepository _hotels;

  Future<List<Hotel>> call(Session session) async {
    final accountId = session.resolvedAccountId;
    if (accountId == null) return session.hotels;
    return (await _hotels.getAllHotels())
        .where((hotel) => hotel.accountId == accountId)
        .toList();
  }
}
