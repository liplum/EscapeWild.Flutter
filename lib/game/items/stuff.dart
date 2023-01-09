import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Stuff {
  static late FuelItemMeta plasticBottle;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = const FuelItemMeta("plastic-bottle", 5.0),
    ]);
  }
}
