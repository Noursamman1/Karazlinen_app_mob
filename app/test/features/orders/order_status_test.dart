import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/repositories/account_repository.dart';

void main() {
  test('demo orders expose normalized status labels', () async {
    const DemoAccountRepository repository = DemoAccountRepository();
    final orders = await repository.fetchOrders();
    expect(orders.first.statusLabel, isNotEmpty);
    expect(orders.first.statusCode, isNotEmpty);
  });
}
