import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:escape_wild_flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'r.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  initFoundation();
  runApp(
    const EscapeWildApp().withEasyLocalization(),
  );
}

extension _AppX on Widget {
  Widget withEasyLocalization() {
    return EasyLocalization(
      supportedLocales: R.supportedLocales,
      path: 'assets/l10n',
      fallbackLocale: R.defaultLocale,
      useFallbackTranslations: true,
      assetLoader: yamlAssetsLoader,
      child: this,
    );
  }
}
