import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/app/router/app_router.dart';
import 'package:karaz_linen_app/core/config/app_config.dart';
import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/i18n/app_localizations.dart';
import 'package:karaz_linen_app/design_system/theme/app_theme.dart';

class KarazApp extends ConsumerWidget {
  const KarazApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    final AppRouter appRouter = ref.watch(appRouterProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: Locale(config.defaultLocaleCode),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        routerConfig: appRouter.config,
        title: 'Karaz Linen',
      ),
    );
  }
}
