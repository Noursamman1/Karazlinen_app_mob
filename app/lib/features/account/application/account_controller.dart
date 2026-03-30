import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';

final profileProvider = FutureProvider<ProfileView>((Ref ref) {
  return ref.watch(accountRepositoryProvider).fetchProfile();
});
