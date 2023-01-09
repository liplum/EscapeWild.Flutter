import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Tools {
  static late Item survivalKnife, oldOxe;

  void register() {
    Contents.items.addAll([
      survivalKnife = Item("survival-knife").asTool(
        level: ToolLevel.high,
        type: ToolType.cutting,
        maxDurability: 40.0,
      ),
      oldOxe = Item("old-oxe").asTool(
        type: ToolType.oxe,
        level: ToolLevel.low,
        maxDurability: 30.0,
      )
    ]);
  }
}
