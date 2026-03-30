import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/network/api_result.dart';

void main() {
  test('api result success calls success branch', () {
    const ApiResult<int> result = ApiSuccess<int>(3);
    final int value = result.when(
      success: (int data) => data,
      failure: (_) => 0,
    );
    expect(value, 3);
  });
}
