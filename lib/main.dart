import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'r.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (!kIsWeb) {
    final appDocDir = await getApplicationDocumentsDirectory();
    R.appDir = appDocDir.path;
    final tmpDir = await getTemporaryDirectory();
    R.tmpDir = tmpDir.path;
    await Hive.initFlutter(R.hiveDir);
  }
  await DB.init();
  registerConverter();
  initPreference();
  runApp(const EscapeWildApp().withEasyLocalization());
  await loadGameContent();
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
