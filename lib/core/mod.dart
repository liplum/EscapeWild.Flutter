import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild_flutter/app.dart';
import 'package:escape_wild_flutter/foundation.dart';
import 'package:escape_wild_flutter/r.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class ModProtocol {
  String get modId;

  String decorateRegisterName(String name);

  String getL10n(String key);

  Future<void> load();

  Future<void> unload();

  Future<void> onLocaleChange();

  bool get unloadable;
}

extension ModProtocolX on ModProtocol {
  bool get isVanilla => identical(this, Vanilla.instance);
}

class ModAssetsLoader {

}

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
  String getL10n(String key) {
    return _key2Translated[key] ?? _defaultKey2Translated[key] ?? key;
  }

  @override
  Future<void> load() async {
    final locale = AppCtx.locale;
    final string2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", locale);
    _key2Translated = _flattenString2Map(string2Map);
    if (locale != R.defaultLocale) {
      final defaultString2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", R.defaultLocale);
      _defaultKey2Translated = _flattenString2Map(defaultString2Map);
    }
  }

  @override
  Future<void> unload() {
    throw UnimplementedError();
  }

  @override
  get unloadable => true;

  @override
  Future<void> onLocaleChange() {
    throw UnimplementedError();
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
  String getL10n(String key) {
    return _key2Translated[key] ?? key;
  }

  @override
  Future<void> load() async {
    loadVanilla();
    _loadL10n();
  }

  @override
  Future<void> unload() async {}

  @override
  get unloadable => false;

  @override
  Future<void> onLocaleChange() async {
    _loadL10n();
  }

  Future<void> _loadL10n() async {
    final locale = AppCtx.locale;
    final string2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", locale);
    _key2Translated = _flattenString2Map(string2Map);
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

mixin Moddable {
  @JsonKey(ignore: true)
  ModProtocol mod = Vanilla.instance;
}

extension ModdableX on Moddable {
  bool get isVanilla => mod.isVanilla;

  bool get isModded => !mod.isVanilla;
}
