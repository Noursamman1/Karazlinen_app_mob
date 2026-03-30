import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karaz_linen_app/features/search/presentation/pages/search_page.dart';

void main() {
  testWidgets('Search page renders search field', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
  });
}
