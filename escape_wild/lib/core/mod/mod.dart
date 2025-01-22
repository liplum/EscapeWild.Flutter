import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:json_annotation/json_annotation.dart';

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

  var _key2Translated = <String, String>{};

  /// Used when key not found in current locale.
  var _fallbackKey2Translated = <String, String>{};

  @override
  String decorateRegisterName(String name) => "$modId-$name";

  @override
  String? tryGetL10n(String key) {
    return _key2Translated[key] ?? _fallbackKey2Translated[key];
  }

  @override
  Future<void> load() async {
    // TODO: Mod loader
    final locale = $context.locale;
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
    final locale = $context.locale;
  }
}

class Vanilla implements ModProtocol {
  Vanilla._();

  static final instance = Vanilla._();
  Map<String, String> _key2Translated = const {};

  /// Used when key not found in current locale.
  Map<String, String> _fallbackKey2Translated = const {};

  @override
  String get modId => "vanilla";

  @override
  String decorateRegisterName(String name) => name;

  @override
  String? tryGetL10n(String key) {
    return _key2Translated[key] ?? _fallbackKey2Translated[key];
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
    final userLocale = $context.locale;
    final actualLocale = tryFindBestMatchedLocale(userLocale, R.defaultLocale, R.supportedLocales);
    final string2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", actualLocale);
    _key2Translated = _flattenString2Map(string2Map);
    if (actualLocale != R.defaultLocale) {
      final fallbackString2Map = await yamlAssetsLoader.load("assets/vanilla/l10n", R.defaultLocale);
      _fallbackKey2Translated = _flattenString2Map(fallbackString2Map);
    }
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
      } else if (v is List) {
        var i = 0;
        for (final item in v) {
          res["$pos$i"] = item.toString();
          i++;
        }
      } else {
        res[pos] = v.toString();
      }
    }
  }

  walk(null, string2Map);
  return res;
}

mixin Moddable implements I18nScopeProtocol {
  @JsonKey(toJson: mod2ModIdFunc, fromJson: modId2ModFunc)
  ModProtocol mod = Vanilla.instance;

  String get name;

  String get registerName => mod.decorateRegisterName(name);

  @override
  String get i18nNamespace => mod.modId;

  static String mod2ModIdFunc(ModProtocol mod) => mod.modId;

  static ModProtocol modId2ModFunc(String modId) => Contents.getModById(modId) ?? Vanilla.instance;

  @override
  String toString() => registerName;
}

extension ModdableX on Moddable {
  bool get isVanilla => mod.isVanilla;

  bool get isModded => !mod.isVanilla;
}
