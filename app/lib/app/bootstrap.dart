import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/app/karaz_app.dart';

void bootstrap() {
  runApp(
    const ProviderScope(
      child: KarazApp(),
    ),
  );
}
