import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/application/protected_state_mapper.dart';
import 'package:karaz_linen_app/features/account/domain/account_access_state.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/cart/application/cart_use_cases.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';

class CartActionResult {
  const CartActionResult._({
    required this.status,
    required this.message,
  });

  const CartActionResult.success(String message)
      : this._(
          status: CartActionStatus.success,
          message: message,
        );

  const CartActionResult.requiresAuth(String message)
      : this._(
          status: CartActionStatus.requiresAuth,
          message: message,
        );

  const CartActionResult.failure(String message)
      : this._(
          status: CartActionStatus.failure,
          message: message,
        );

  final CartActionStatus status;
  final String message;

  bool get isSuccess => status == CartActionStatus.success;
  bool get needsAuth => status == CartActionStatus.requiresAuth;
}

enum CartActionStatus {
  success,
  requiresAuth,
  failure,
}

final cartProvider = FutureProvider<CartView>((Ref ref) {
  return ref.watch(loadCartUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<CartView>> cartStateProvider = Provider<ProtectedAsyncState<CartView>>((Ref ref) {
  final AccountAccessState access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<CartView>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<CartView>(
    access: access,
    asyncValue: ref.watch(cartProvider),
    isEmpty: (CartView value) => value.items.isEmpty,
    emptyMessage: 'لا توجد عناصر في السلة بعد.',
    errorMessage: 'تعذر تحميل السلة',
  );
});

final Provider<int> cartItemCountProvider = Provider<int>((Ref ref) {
  final ProtectedAsyncState<CartView> state = ref.watch(cartStateProvider);
  return state.status == ProtectedAsyncStatus.ready ? state.data!.itemCount : 0;
});

final Provider<CartActions> cartActionsProvider = Provider<CartActions>((Ref ref) {
  return CartActions(ref);
});

class CartActions {
  CartActions(this._ref);

  final Ref _ref;

  Future<CartActionResult> addFromProductSelection({
    required String productId,
    required String fallbackSku,
    required String name,
    required int quantity,
    required ProductSelectionSummary selection,
  }) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CartActionResult.requiresAuth(access.guardMessage);
    }

    try {
      final AddCartItemInput input = AddCartItemInput(
        productId: productId,
        sku: selection.previewSku.isEmpty ? fallbackSku : selection.previewSku,
        name: name,
        quantity: quantity,
        unitPrice: selection.previewPrice,
        thumbnail: selection.previewImage,
        selectedOptions: selection.selectedOptions
            .map(
              (SelectedProductOption option) => CartSelectedOptionView(
                code: option.code,
                label: option.label,
                value: option.valueLabel,
              ),
            )
            .toList(growable: false),
      );
      await _ref.read(addCartItemUseCaseProvider).call(input);
      _ref.invalidate(cartProvider);
      return const CartActionResult.success('تمت إضافة المنتج إلى السلة.');
    } catch (_) {
      return const CartActionResult.failure('تعذر إضافة المنتج إلى السلة.');
    }
  }

  Future<CartActionResult> updateItemQuantity(String itemId, int quantity) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CartActionResult.requiresAuth(access.guardMessage);
    }
    try {
      await _ref.read(updateCartItemQuantityUseCaseProvider).call(itemId, quantity);
      _ref.invalidate(cartProvider);
      return const CartActionResult.success('تم تحديث الكمية.');
    } catch (_) {
      return const CartActionResult.failure('تعذر تحديث الكمية.');
    }
  }

  Future<CartActionResult> removeItem(String itemId) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CartActionResult.requiresAuth(access.guardMessage);
    }
    try {
      await _ref.read(removeCartItemUseCaseProvider).call(itemId);
      _ref.invalidate(cartProvider);
      return const CartActionResult.success('تم حذف العنصر من السلة.');
    } catch (_) {
      return const CartActionResult.failure('تعذر حذف العنصر.');
    }
  }
}
