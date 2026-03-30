import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/app/presentation/auth_required_page.dart';
import 'package:karaz_linen_app/app/screens/home_page.dart';
import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/session/session_state.dart';
import 'package:karaz_linen_app/features/account/presentation/pages/account_overview_page.dart';
import 'package:karaz_linen_app/features/address_book/presentation/pages/address_book_page.dart';
import 'package:karaz_linen_app/features/address_book/presentation/pages/address_form_page.dart';
import 'package:karaz_linen_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:karaz_linen_app/features/orders/presentation/pages/order_details_page.dart';
import 'package:karaz_linen_app/features/orders/presentation/pages/orders_list_page.dart';
import 'package:karaz_linen_app/features/product/presentation/pages/product_details_page.dart';
import 'package:karaz_linen_app/features/search/presentation/pages/search_page.dart';

class AppRouter {
  AppRouter({required SessionState sessionState})
      : config = GoRouter(
          initialLocation: '/',
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'home',
              builder: (_, __) => const HomePage(),
            ),
            GoRoute(
              path: '/catalog',
              name: 'catalog',
              builder: (_, __) => const CatalogPage(),
            ),
            GoRoute(
              path: '/auth-required',
              name: 'auth-required',
              builder: (_, __) => const AuthRequiredPage(),
            ),
            GoRoute(
              path: '/product/:productId',
              name: 'product',
              builder: (_, GoRouterState state) => ProductDetailsPage(productId: state.pathParameters['productId']!),
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (_, __) => const SearchPage(),
            ),
            GoRoute(
              path: '/account',
              name: 'account',
              builder: (_, __) => const AccountOverviewPage(),
            ),
            GoRoute(
              path: '/account/addresses',
              name: 'addresses',
              builder: (_, __) => const AddressBookPage(),
            ),
            GoRoute(
              path: '/account/addresses/new',
              name: 'address-new',
              builder: (_, __) => const AddressFormPage(),
            ),
            GoRoute(
              path: '/account/orders',
              name: 'orders',
              builder: (_, __) => const OrdersListPage(),
            ),
            GoRoute(
              path: '/account/orders/:orderNumber',
              name: 'order-details',
              builder: (_, GoRouterState state) => OrderDetailsPage(orderNumber: state.pathParameters['orderNumber']!),
            ),
          ],
          redirect: (_, GoRouterState state) {
            final bool isProtected = state.fullPath?.startsWith('/account') ?? false;
            final bool isAuthPage = state.fullPath == '/auth-required';
            if (isProtected && !sessionState.isAuthenticated) {
              return '/auth-required';
            }
            if (isAuthPage && sessionState.isAuthenticated) {
              return '/account';
            }
            return null;
          },
        );

  final GoRouter config;
}

final Provider<AppRouter> appRouterProvider = Provider<AppRouter>((ProviderRef<AppRouter> ref) {
  final SessionState session = ref.watch(sessionControllerProvider);
  return AppRouter(sessionState: session);
});
