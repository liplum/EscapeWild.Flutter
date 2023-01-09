import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Stuff {
  static late FuelItemMeta plasticBottle, sticks, cutGrass, log, dryLichen;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = const FuelItemMeta("plastic-bottle", 5.0),
      sticks = const FuelItemMeta("sticks", 2.0),
      cutGrass = const FuelItemMeta("cut-grass", 5.0),
      log = const FuelItemMeta("log", 20.0),
      dryLichen = const FuelItemMeta("dry-Lichen", 10.0),
    ]);
  }
}
