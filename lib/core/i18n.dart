import 'package:easy_localization/easy_localization.dart';

String i18n(String key) {
  return key.tr();
  // return I18n.get(i18nNamespace, key);
}
