import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Medicine {
  static late AttrModifyItemMeta bandage, firstAidKit;

  static void registerAl() {
    Contents.items.addAll([
      bandage = AttrModifyItemMeta(
        "bandage",
        UseType.use,
        [
          Attr.health + 0.3,
        ],
      )
    ]);
  }
}
