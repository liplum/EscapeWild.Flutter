import 'package:escape_wild_flutter/core/player.dart';
import 'package:escape_wild_flutter/game/items/foods.dart';
import 'package:escape_wild_flutter/game/items/medicine.dart';
import 'package:escape_wild_flutter/game/items/stuff.dart';
import 'package:escape_wild_flutter/game/items/tools.dart';
export 'utils/random.dart';
export 'utils/collection.dart';

final player = Player();

void initFoundation() {
  Foods.registerAll();
  Medicines.registerAll();
  Stuff.registerAll();
  Tools.registerAll();
}
