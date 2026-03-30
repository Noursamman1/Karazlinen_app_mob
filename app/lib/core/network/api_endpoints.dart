class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/v1/auth/login';
  static const String refresh = '/v1/auth/refresh';
  static const String logout = '/v1/auth/logout';
  static const String me = '/v1/auth/me';
  static const String categories = '/v1/catalog/categories';
  static const String products = '/v1/catalog/products';
  static String productDetail(String productId) => '/v1/catalog/products/$productId';
  static const String profile = '/v1/account/profile';
  static const String addresses = '/v1/account/addresses';
  static String address(String addressId) => '/v1/account/addresses/$addressId';
  static const String orders = '/v1/orders';
  static String order(String orderNumber) => '/v1/orders/$orderNumber';
}
