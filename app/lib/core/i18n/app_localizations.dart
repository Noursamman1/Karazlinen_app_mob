import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('ar'));
  }

  static const Map<String, Map<String, String>> _strings = <String, Map<String, String>>{
    'ar': <String, String>{
      'appTitle': 'كاراز لينن',
      'catalog': 'التسوق',
      'account': 'حسابي',
      'searchHint': 'ابحثي عن منتج أو مجموعة',
      'authRequiredTitle': 'تسجيل الدخول مطلوب',
      'authRequiredBody': 'استخدمي حساب الموقع الحالي للوصول إلى الطلبات والعناوين.',
      'previewSession': 'دخول تجريبي',
      'retry': 'إعادة المحاولة',
      'emptyState': 'لا توجد نتائج حالياً',
      'errorState': 'حدث خطأ غير متوقع',
      'addresses': 'العناوين',
      'orders': 'الطلبات',
    },
    'en': <String, String>{
      'appTitle': 'Karaz Linen',
      'catalog': 'Shop',
      'account': 'Account',
      'searchHint': 'Search products or collections',
      'authRequiredTitle': 'Sign in required',
      'authRequiredBody': 'Use your existing website account to access orders and addresses.',
      'previewSession': 'Preview sign-in',
      'retry': 'Retry',
      'emptyState': 'Nothing to show right now',
      'errorState': 'Something went wrong',
      'addresses': 'Addresses',
      'orders': 'Orders',
    },
  };

  String text(String key) => _strings[locale.languageCode]?[key] ?? _strings['ar']![key] ?? key;

  String get brandName => text('appTitle');
  String get homeTitle =>
      locale.languageCode == 'ar' ? 'نسيج هادئ لحياة أنيقة' : 'Calm linen for elevated living';
  String get homeSubtitle =>
      locale.languageCode == 'ar'
          ? 'تصفحي التشكيلات الأساسية، واديري الطلبات، وراجعي الحساب من تجربة عربية أولاً.'
          : 'Browse signature collections, manage orders, and review your account from an Arabic-first experience.';
  String get catalog => text('catalog');
  String get search => locale.languageCode == 'ar' ? 'البحث' : 'Search';
  String get account => text('account');
  String get loading => locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  String get empty => text('emptyState');
  String get retry => text('retry');
  String get addresses => text('addresses');
  String get orders => text('orders');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
