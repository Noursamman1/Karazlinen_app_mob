import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaz_linen_app/features/product/application/product_controller.dart';

void main() {
  test('product selection tracks chosen values', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(productSelectionProvider('sku-100').notifier);
    notifier.select('size', 'queen');

    expect(container.read(productSelectionProvider('sku-100'))['size'], 'queen');
  });
}
