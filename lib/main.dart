import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'r.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    const MyApp().withEasyLocalization(),
  );
}

extension _AppX on Widget {
  Widget withEasyLocalization() {
    return EasyLocalization(
      supportedLocales: R.supportedLocales,
      path: 'assets/l10n',
      fallbackLocale: R.defaultLocale,
      useFallbackTranslations: true,
      child: this,
    );
  }
}
