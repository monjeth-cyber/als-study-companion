import 'package:flutter_test/flutter_test.dart';
import 'package:backend_services/backend_services.dart';

void main() {
  test('SyncResult properties', () {
    const result = SyncResult(
      pushed: 5,
      pulled: 3,
      success: true,
      message: 'Sync completed',
    );
    expect(result.pushed, 5);
    expect(result.pulled, 3);
    expect(result.success, true);
  });
}
