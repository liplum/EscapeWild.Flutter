import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:escape_wild/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:escape_wild/game/items/medicine.dart';
import 'package:escape_wild/game/items/stuff.dart';
import 'package:escape_wild/game/items/tools.dart';
import 'package:escape_wild/game/recipes/craft.dart';
import 'package:escape_wild/db.dart';
import 'package:escape_wild/game/register.dart' as game_register;
import 'package:escape_wild/core/register.dart' as core_register;
import 'package:jconverter/jconverter.dart';

export 'package:escape_wild/game/items/foods.dart';
export 'package:escape_wild/game/recipes/craft.dart';
export 'package:escape_wild/game/items/medicine.dart';
export 'package:escape_wild/game/items/stuff.dart';
export 'package:escape_wild/game/items/tools.dart';
export 'package:escape_wild/i18n.dart';
export 'package:escape_wild/design/component.dart';
export 'package:escape_wild/design/dialog.dart';
export 'package:escape_wild/design/extension.dart';
export 'package:escape_wild/utils.dart';
export 'package:escape_wild/db.dart';
export 'package:escape_wild/design/top.dart';
export 'package:escape_wild/design/window.dart';

class Measurement {
  Measurement._();

  static var mass = UnitConverter.gram;

  static reload() {
    Measurement.mass = UnitConverter.getMassForName(DB.preference.getMeasurementSystemOf(PhysicalQuantity.mass.name));
  }

  static void set(PhysicalQuantity quantity, UnitConverter cvt) {
    DB.preference.setMeasurementSystemOf(PhysicalQuantity.mass.name, cvt.name);
  }

  static UnitConverter? get(PhysicalQuantity quantity) {
    if (quantity == PhysicalQuantity.mass) {
      return mass;
    }
    return null;
  }

  static Map<PhysicalQuantity, UnitConverter> toMap() {
    final res = <PhysicalQuantity, UnitConverter>{};
    for (final quantity in PhysicalQuantity.all) {
      final cvt = get(quantity);
      if (cvt != null) {
        res[quantity] = cvt;
      }
    }
    return res;
  }
}

final yamlAssetsLoader = YamlAssetLoader();
final isGameLoaded = ValueNotifier(false);
var isGameContentLoaded = false;
var isL10nLoaded = false;

Future<void> loadGameContent() async {
  // load vanilla
  await Vanilla.instance.load();
  isGameContentLoaded = true;
  _checkGameLoadState();
}

Future<void> loadL10n() async {
  await Vanilla.instance.loadL10n();
  isL10nLoaded = true;
  _checkGameLoadState();
}

Future<void> onLocaleChange() async {
  await Vanilla.instance.onLocaleChange();
}

void _checkGameLoadState() {
  if (isGameContentLoaded && isL10nLoaded) {
    isGameLoaded.value = true;
  }
}

Future<void> initPlayer() async {
  await player.init();
}

Future<void> onNewGame() async {
  await player.restart();
}

Future<void> loadGameSave(String gameSave) async {
  await player.init();
  player.loadFromJson(gameSave);
}

void loadVanilla() {
  Foods.registerAll();
  Medicines.registerAll();
  Stuff.registerAll();
  Tools.registerAll();
  CraftRecipes.registerAll();
}

void registerConverter() {
  Cvt.logger = JConverterLogger(onError: (m, e, s) => print("$m,$e,$s"));
  core_register.registerTypes(Cvt);
  game_register.registerTypes(Cvt);
}

void initPreference() {
  Measurement.reload();
}
