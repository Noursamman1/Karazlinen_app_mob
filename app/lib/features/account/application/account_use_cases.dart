import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/repositories/account_repository.dart';
import 'package:karaz_linen_app/core/di/service_locator.dart';

class LoadAccountProfileUseCase {
  const LoadAccountProfileUseCase(this._repository);

  final AccountRepository _repository;

  Future<ProfileView> call() {
    return _repository.fetchProfile();
  }
}

class LoadAddressBookUseCase {
  const LoadAddressBookUseCase(this._repository);

  final AccountRepository _repository;

  Future<List<AddressView>> call() {
    return _repository.fetchAddresses();
  }
}

class LoadOrdersUseCase {
  const LoadOrdersUseCase(this._repository);

  final AccountRepository _repository;

  Future<OrdersListingView> call() {
    return _repository.fetchOrders();
  }
}

class LoadOrderDetailUseCase {
  const LoadOrderDetailUseCase(this._repository);

  final AccountRepository _repository;

  Future<OrderDetailView> call(String orderNumber) {
    return _repository.fetchOrderDetail(orderNumber);
  }
}

final Provider<LoadAccountProfileUseCase> loadAccountProfileUseCaseProvider =
    Provider<LoadAccountProfileUseCase>((Ref ref) {
  return LoadAccountProfileUseCase(ref.watch(accountRepositoryProvider));
});

final Provider<LoadAddressBookUseCase> loadAddressBookUseCaseProvider =
    Provider<LoadAddressBookUseCase>((Ref ref) {
  return LoadAddressBookUseCase(ref.watch(accountRepositoryProvider));
});

final Provider<LoadOrdersUseCase> loadOrdersUseCaseProvider = Provider<LoadOrdersUseCase>((Ref ref) {
  return LoadOrdersUseCase(ref.watch(accountRepositoryProvider));
});

final Provider<LoadOrderDetailUseCase> loadOrderDetailUseCaseProvider =
    Provider<LoadOrderDetailUseCase>((Ref ref) {
  return LoadOrderDetailUseCase(ref.watch(accountRepositoryProvider));
});
