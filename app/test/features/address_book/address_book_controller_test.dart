import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karaz_linen_app/features/address_book/application/address_book_controller.dart';

void main() {
  test('addresses provider can be read from a container', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(addressesProvider), isA<AsyncValue>());
  });
}
