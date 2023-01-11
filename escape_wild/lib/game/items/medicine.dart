import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

class Medicines {
  static late Item bandage, firstAidKit, herbs;

  static void registerAll() {
    Contents.items.addAll([
      bandage = Item.unmergeable("bandage", mass: 50).asUsable([
        Attr.health + 0.3,
      ]),
      firstAidKit = Item.unmergeable("first-aid-kit", mass: 500).asUsable([
        Attr.health + 0.65,
        Attr.energy + 0.2,
      ]),
      herbs = Item.mergeable("licorice", mass: 50).asUsable([
        Attr.health + 0.1,
        //Boiling water with it can alleviate the dehydration caused by diarrhea,
        // and can also reduce phlegm and cough
      ]),
    ]);
  }
}
