import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Medicines {
  static late Item bandage, firstAidKit, licorice;

  static void registerAll() {
    Contents.items.addAll([
      bandage = Item("bandage").asUsable([
        Attr.health + 0.3,
      ]),
      firstAidKit = Item("first-aid-kit").asUsable([
        Attr.health + 0.65,
        Attr.energy + 0.2,
      ]),
      licorice = Item("licorice").asUsable([
        Attr.health + 0.1,
        //Boiling water with it can alleviate the dehydration caused by diarrhea,
        // and can also reduce phlegm and cough
      ]),
    ]);
  }
}
