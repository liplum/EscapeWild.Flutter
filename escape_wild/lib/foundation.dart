import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:escape_wild/core/player.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:escape_wild/game/items/medicine.dart';
import 'package:escape_wild/game/items/stuff.dart';
import 'package:escape_wild/game/items/tools.dart';
export 'utils/random.dart';
export 'utils/collection.dart';

final player = Player();
final yamlAssetsLoader = YamlAssetLoader();

void initFoundation() {
  loadVanilla();
}

void loadVanilla() {
  Foods.registerAll();
  Medicines.registerAll();
  Stuff.registerAll();
  Tools.registerAll();
}
