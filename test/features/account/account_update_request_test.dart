import 'package:booking_app_mobile/features/account/data/models/account_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a password change sends the current password with the new one', () {
    expect(
      const AccountUpdateRequest(password: 'new-pass-2026', currentPassword: 'old-pass-2026').toJson(),
      {'password': 'new-pass-2026', 'currentPassword': 'old-pass-2026'},
    );
  });

  test('locking sends only the status', () {
    expect(const AccountUpdateRequest(active: false).toJson(), {'status': false});
  });
}
