import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karaz_linen_app/features/product/presentation/pages/product_details_page.dart';

void main() {
  testWidgets('Product details page renders loading state first', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProductDetailsPage(productId: 'p-1')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
