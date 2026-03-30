import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';

void main() {
  test('profile provider can be read from a container', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(profileProvider), isA<AsyncValue>());
  });
}
