import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/config/app_config.dart';
import 'package:karaz_linen_app/core/logging/app_logger.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/network/http_client.dart';
import 'package:karaz_linen_app/core/repositories/account_repository.dart';
import 'package:karaz_linen_app/core/repositories/catalog_repository.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';
import 'package:karaz_linen_app/core/session/session_controller.dart';
import 'package:karaz_linen_app/core/session/session_state.dart';

final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((ProviderRef<AppConfig> ref) {
  return AppConfig.preview();
});

final Provider<AppLogger> appLoggerProvider = Provider<AppLogger>((ProviderRef<AppLogger> ref) {
  return const DebugAppLogger();
});

final Provider<AppHttpClient> appHttpClientProvider = Provider<AppHttpClient>((ProviderRef<AppHttpClient> ref) {
  return AppHttpClient(
    config: ref.watch(appConfigProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final Provider<CatalogRepository> catalogRepositoryProvider = Provider<CatalogRepository>((ProviderRef<CatalogRepository> ref) {
  return const DemoCatalogRepository();
});

final Provider<AccountRepository> accountRepositoryProvider = Provider<AccountRepository>((ProviderRef<AccountRepository> ref) {
  return const DemoAccountRepository();
});

final Provider<CartRepository> cartRepositoryProvider = Provider<CartRepository>((ProviderRef<CartRepository> ref) {
  return DemoCartRepository();
});

final StateNotifierProvider<SessionController, SessionState> sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((StateNotifierProviderRef<SessionController, SessionState> ref) {
  return SessionController();
});

final Provider<ProfileView> previewProfileProvider = Provider<ProfileView>((ProviderRef<ProfileView> ref) {
  return const ProfileView(
    customerId: 'cust-preview',
    firstName: 'نورة',
    lastName: 'التميمي',
    email: 'preview@example.com',
    phone: '+966500000000',
  );
});
