import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';

class AssignCheckoutAddressesUseCase {
  const AssignCheckoutAddressesUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call(CartAddressAssignmentInput input) {
    return _repository.assignAddresses(input);
  }
}

class LoadCheckoutShippingMethodsUseCase {
  const LoadCheckoutShippingMethodsUseCase(this._repository);

  final CartRepository _repository;

  Future<List<ShippingMethodView>> call() {
    return _repository.listShippingMethods();
  }
}

class SelectCheckoutShippingMethodUseCase {
  const SelectCheckoutShippingMethodUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call({
    required String carrierCode,
    required String methodCode,
  }) {
    return _repository.selectShippingMethod(
      carrierCode: carrierCode,
      methodCode: methodCode,
    );
  }
}

class LoadCheckoutPaymentMethodsUseCase {
  const LoadCheckoutPaymentMethodsUseCase(this._repository);

  final CartRepository _repository;

  Future<List<PaymentMethodView>> call() {
    return _repository.listPaymentMethods();
  }
}

class SelectCheckoutPaymentMethodUseCase {
  const SelectCheckoutPaymentMethodUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call(String code) {
    return _repository.selectPaymentMethod(code);
  }
}

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final CartRepository _repository;

  Future<PlaceOrderResultView> call(PlaceOrderInput input) {
    return _repository.placeOrder(input);
  }
}

final Provider<AssignCheckoutAddressesUseCase> assignCheckoutAddressesUseCaseProvider =
    Provider<AssignCheckoutAddressesUseCase>((Ref ref) {
  return AssignCheckoutAddressesUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<LoadCheckoutShippingMethodsUseCase> loadCheckoutShippingMethodsUseCaseProvider =
    Provider<LoadCheckoutShippingMethodsUseCase>((Ref ref) {
  return LoadCheckoutShippingMethodsUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<SelectCheckoutShippingMethodUseCase> selectCheckoutShippingMethodUseCaseProvider =
    Provider<SelectCheckoutShippingMethodUseCase>((Ref ref) {
  return SelectCheckoutShippingMethodUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<LoadCheckoutPaymentMethodsUseCase> loadCheckoutPaymentMethodsUseCaseProvider =
    Provider<LoadCheckoutPaymentMethodsUseCase>((Ref ref) {
  return LoadCheckoutPaymentMethodsUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<SelectCheckoutPaymentMethodUseCase> selectCheckoutPaymentMethodUseCaseProvider =
    Provider<SelectCheckoutPaymentMethodUseCase>((Ref ref) {
  return SelectCheckoutPaymentMethodUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<PlaceOrderUseCase> placeOrderUseCaseProvider = Provider<PlaceOrderUseCase>((Ref ref) {
  return PlaceOrderUseCase(ref.watch(cartRepositoryProvider));
});
