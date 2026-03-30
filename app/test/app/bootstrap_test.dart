import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/config/app_config.dart';

void main() {
  test('preview config defaults to Arabic first', () {
    final AppConfig config = AppConfig.preview();
    expect(config.defaultLocaleCode, 'ar');
    expect(config.supportedLocaleCodes, containsAll(<String>['ar', 'en']));
  });
}
