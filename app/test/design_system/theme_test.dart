import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';

void main() {
  test('spacing scale stays ordered', () {
    expect(AppSpacing.xs < AppSpacing.sm, isTrue);
    expect(AppSpacing.sm < AppSpacing.md, isTrue);
    expect(AppSpacing.md < AppSpacing.lg, isTrue);
  });
}
