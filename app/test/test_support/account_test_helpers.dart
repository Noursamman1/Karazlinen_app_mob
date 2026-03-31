import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';

import 'fake_account_repository.dart';

ProviderContainer createAccountTestContainer({
  FakeAccountRepository? repository,
  CartRepository? cartRepository,
  bool authenticated = false,
  bool expired = false,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      if (repository != null) accountRepositoryProvider.overrideWithValue(repository),
      if (cartRepository != null) cartRepositoryProvider.overrideWithValue(cartRepository),
    ],
  );

  if (authenticated || expired) {
    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );
  }

  if (expired) {
    container.read(sessionControllerProvider.notifier).expireSession();
  }

  return container;
}

Widget buildAccountTestApp({
  required ProviderContainer container,
  required Widget child,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );
}
