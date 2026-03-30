import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/test/test_support/fake_account_repository.dart';

void main() {
  ProviderContainer createContainer(FakeAccountRepository repository) {
    return ProviderContainer(
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  test('account profile state requires sign-in without fetching protected data', () {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    final ProtectedAsyncState<ProfileView> state = container.read(accountProfileStateProvider);

    expect(state.status, ProtectedAsyncStatus.requiresAuth);
    expect(
      state.message,
      'تسجيل الدخول مطلوب للوصول إلى الحساب والطلبات والعناوين.',
    );
    expect(repository.profileFetchCount, 0);
  });

  test('account profile state resolves to ready for authenticated sessions', () async {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    expect(
      container.read(accountProfileStateProvider).status,
      ProtectedAsyncStatus.loading,
    );

    await container.read(profileProvider.future);

    final ProtectedAsyncState<ProfileView> state = container.read(accountProfileStateProvider);

    expect(state.status, ProtectedAsyncStatus.ready);
    expect(state.data, isNotNull);
    expect(state.data.fullName, 'نورة التميمي');
    expect(repository.profileFetchCount, 1);
  });

  test('account profile state returns requires-auth for expired sessions', () {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );
    container.read(sessionControllerProvider.notifier).expireSession();

    final ProtectedAsyncState<ProfileView> state = container.read(accountProfileStateProvider);

    expect(state.status, ProtectedAsyncStatus.requiresAuth);
    expect(
      state.message,
      'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى للمتابعة.',
    );
  });

  test('account profile state surfaces repository errors for authenticated sessions', () async {
    final FakeAccountRepository repository = FakeAccountRepository(
      profileError: StateError('profile failed'),
    );
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    await expectLater(
      container.read(profileProvider.future),
      throwsA(isA<StateError>()),
    );

    final ProtectedAsyncState<ProfileView> state = container.read(accountProfileStateProvider);

    expect(state.status, ProtectedAsyncStatus.error);
    expect(state.message, 'تعذر تحميل الملف الشخصي');
    expect(repository.profileFetchCount, 1);
  });
}
