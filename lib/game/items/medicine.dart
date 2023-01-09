import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Medicines {
  static late AttrModifyItemMeta bandage, firstAidKit;

  static void registerAll() {
    Contents.items.addAll([
      bandage = AttrModifyItemMeta(
        "bandage",
        UseType.use,
        [
          Attr.health + 0.3,
        ],
      ),
      firstAidKit = AttrModifyItemMeta(
        "first-aid-kit",
        UseType.use,
        [
          Attr.health + 0.3,
          Attr.energy + 0.2,
        ],
      ),
    ]);
  }
}
