import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:escape_wild/game/items/medicine.dart';
import 'package:escape_wild/game/items/stuff.dart';
import 'package:escape_wild/game/items/tools.dart';
export 'package:escape_wild/game/items/foods.dart';
export 'package:escape_wild/game/items/medicine.dart';
export 'package:escape_wild/game/items/stuff.dart';
export 'package:escape_wild/game/items/tools.dart';
export 'package:escape_wild/utils/random.dart';
export 'package:escape_wild/design/component.dart';
export 'package:escape_wild/utils/collection.dart';

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

void loadVanilla() {
  Foods.registerAll();
  Medicines.registerAll();
  Stuff.registerAll();
  Tools.registerAll();
}
