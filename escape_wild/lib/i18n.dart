import 'package:escape_wild/core.dart';

// ignore: non_constant_identifier_names
final I18n = I18nImpl();

class I18nImpl {
  final defaultNamespace = Vanilla.instance.modId;
  final Map<String, L10nProvider> _namespace2L10n = {};

  void load(String namespace, L10nProvider l10n) {
    _namespace2L10n[namespace] = l10n;
  }

  void unload(String namespace) {
    _namespace2L10n.remove(namespace);
  }

  String get(String namespace, String key) {
    final l10n = _namespace2L10n[namespace];
    if (l10n == null) return key;
    return l10n.tryGetL10n(key) ?? key;
  }

  operator [](String key) {
    return get(defaultNamespace, key);
  }
}
