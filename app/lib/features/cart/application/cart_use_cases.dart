import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';

class LoadCartUseCase {
  const LoadCartUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call() {
    return _repository.fetchCart();
  }
}

class AddCartItemUseCase {
  const AddCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call(AddCartItemInput input) {
    return _repository.addItem(input);
  }
}

class UpdateCartItemQuantityUseCase {
  const UpdateCartItemQuantityUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call(String itemId, int quantity) {
    return _repository.updateItemQuantity(itemId, quantity);
  }
}

class RemoveCartItemUseCase {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<CartView> call(String itemId) {
    return _repository.removeItem(itemId);
  }
}

final Provider<LoadCartUseCase> loadCartUseCaseProvider = Provider<LoadCartUseCase>((Ref ref) {
  return LoadCartUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<AddCartItemUseCase> addCartItemUseCaseProvider = Provider<AddCartItemUseCase>((Ref ref) {
  return AddCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<UpdateCartItemQuantityUseCase> updateCartItemQuantityUseCaseProvider =
    Provider<UpdateCartItemQuantityUseCase>((Ref ref) {
  return UpdateCartItemQuantityUseCase(ref.watch(cartRepositoryProvider));
});

final Provider<RemoveCartItemUseCase> removeCartItemUseCaseProvider = Provider<RemoveCartItemUseCase>((Ref ref) {
  return RemoveCartItemUseCase(ref.watch(cartRepositoryProvider));
});
