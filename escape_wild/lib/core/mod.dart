import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/i18n.dart';
import 'package:escape_wild/r.dart';
import 'package:json_annotation/json_annotation.dart';

import 'i18n.dart';

abstract class ModProtocol extends L10nProvider {
  String get modId;

  String decorateRegisterName(String name);

  Future<void> load();

  Future<void> loadL10n();

  Future<void> unload();

  Future<void> onLocaleChange();

  bool get unloadable;
}

extension ModProtocolX on ModProtocol {
  bool get isVanilla => identical(this, Vanilla.instance);
}

class ModAssetsLoader {}

class Mod implements ModProtocol {
  @override
  final String modId;

  Mod(this.modId);

  Map<String, String> _key2Translated = const {};

  /// Used when key not found in current locale.
  Map<String, String> _defaultKey2Translated = const {};

  @override
  String decorateRegisterName(String name) => "$modId-$name";

  @override
  String? tryGetL10n(String key) {
    return _key2Translated[key] ?? _defaultKey2Translated[key];
  }

  @override
  Future<void> load() async {
    // TODO: Mod loader
    final locale = AppCtx.locale;
  }

  @override
  Future<void> unload() async {}

  @override
  get unloadable => true;

  @override
  Future<void> onLocaleChange() async {
    await loadL10n();
  }

  @override
  Future<void> loadL10n() async {
    final locale = AppCtx.locale;
  }
}

class Vanilla implements ModProtocol {
  Vanilla._();

  static final instance = Vanilla._();
  Map<String, String> _key2Translated = const {};

  @override
  String get modId => "vanilla";

  @override
  String decorateRegisterName(String name) => name;

  @override
  String? tryGetL10n(String key) {
    return _key2Translated[key];
  }

  @override
  Future<void> load() async {
    loadVanilla();
  }

  @override
  Future<void> unload() async {}

  @override
  get unloadable => false;

  @override
  Future<void> onLocaleChange() async {
    loadL10n();
  }

  @override
  Future<void> loadL10n() async {
    final userLocale = AppCtx.locale;
    final actualLocale = tryFindBestMatchedLocale(userLocale, R.defaultLocale, R.supportedLocales);
    final string2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", actualLocale);
    _key2Translated = _flattenString2Map(string2Map);
    I18n.load(modId, this);
  }
}

Map<String, String> _flattenString2Map(Map<String, dynamic> string2Map) {
  final res = <String, String>{};
  void walk(String? parent, Map cur) {
    for (final p in cur.entries) {
      final k = p.key;
      final v = p.value;
      final pos = parent != null ? "$parent.$k" : "$k";
      if (v is Map) {
        walk(pos, v);
      } else {
        res[pos] = v.toString();
      }
    }
  }

  walk(null, string2Map);
  return res;
}

mixin Moddable implements I18nScopeProtocol {
  @JsonKey(ignore: true)
  ModProtocol mod = Vanilla.instance;

  @override
  String get i18nNamespace => mod.modId;
}

extension ModdableX on Moddable {
  bool get isVanilla => mod.isVanilla;

  bool get isModded => !mod.isVanilla;
}
