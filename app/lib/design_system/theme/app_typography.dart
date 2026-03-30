import 'package:flutter/material.dart';

import 'package:karaz_linen_app/design_system/theme/app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme build() {
    const String displayFamily = 'Georgia';
    const String bodyFamily = 'SF Pro Text';
    return const TextTheme(
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.2, fontFamily: displayFamily, color: AppColors.ink),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: displayFamily, color: AppColors.ink),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: displayFamily, color: AppColors.ink),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, fontFamily: bodyFamily, color: AppColors.ink),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, fontFamily: bodyFamily, color: AppColors.ink),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, fontFamily: bodyFamily, color: AppColors.mutedInk),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: bodyFamily, color: AppColors.ink),
    );
  }
}
