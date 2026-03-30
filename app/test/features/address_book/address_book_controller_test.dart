import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/address_book/application/address_book_controller.dart';
import 'package:karaz_linen_app/test/test_support/fake_account_repository.dart';

void main() {
  ProviderContainer createContainer(FakeAccountRepository repository) {
    return ProviderContainer(
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  test('address book state requires sign-in without fetching protected data', () {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    final ProtectedAsyncState<List<AddressView>> state = container.read(addressBookStateProvider);

    expect(state.status, ProtectedAsyncStatus.requiresAuth);
    expect(repository.addressesFetchCount, 0);
  });

  test('address book state becomes ready for authenticated sessions', () async {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    expect(
      container.read(addressBookStateProvider).status,
      ProtectedAsyncStatus.loading,
    );

    await container.read(addressesProvider.future);

    final ProtectedAsyncState<List<AddressView>> state = container.read(addressBookStateProvider);

    expect(state.status, ProtectedAsyncStatus.ready);
    expect(state.data, hasLength(1));
    expect(repository.addressesFetchCount, 1);
  });

  test('address book state becomes empty when no addresses are available', () async {
    final FakeAccountRepository repository = FakeAccountRepository(
      addresses: const <AddressView>[],
    );
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    await container.read(addressesProvider.future);

    final ProtectedAsyncState<List<AddressView>> state = container.read(addressBookStateProvider);

    expect(state.status, ProtectedAsyncStatus.empty);
    expect(state.message, 'لا توجد عناوين محفوظة بعد.');
  });

  test('address book state surfaces repository errors', () async {
    final FakeAccountRepository repository = FakeAccountRepository(
      addressesError: StateError('addresses failed'),
    );
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    await expectLater(
      container.read(addressesProvider.future),
      throwsA(isA<StateError>()),
    );

    final ProtectedAsyncState<List<AddressView>> state = container.read(addressBookStateProvider);

    expect(state.status, ProtectedAsyncStatus.error);
    expect(state.message, 'تعذر تحميل العناوين');
  });
}
