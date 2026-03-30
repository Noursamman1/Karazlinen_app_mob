enum AppFlavor { development, staging, production }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.defaultLocaleCode,
    required this.supportedLocaleCodes,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String defaultLocaleCode;
  final List<String> supportedLocaleCodes;

  factory AppConfig.preview() {
    return const AppConfig(
      flavor: AppFlavor.development,
      apiBaseUrl: 'https://api.example.com',
      defaultLocaleCode: 'ar',
      supportedLocaleCodes: <String>['ar', 'en'],
    );
  }
}
