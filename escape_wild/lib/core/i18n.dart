import 'package:escape_wild/i18n.dart';

abstract class L10nProvider{
  String? tryGetL10n(String key);
}

abstract class I18nScopeProtocol {
  String get i18nNamespace;
}

extension I18nScopeProtocolX on I18nScopeProtocol {
  String i18n(String key) {
    return I18n.get(i18nNamespace, key);
  }
}
