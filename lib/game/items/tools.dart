import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Tools {
  static late ToolItemMeta survivalKnife, oldOxe;

  void register() {
    Contents.items.addAll([
      survivalKnife = ToolItemMeta(
        "survival-knife",
        toolLevel: ToolLevel.high,
        toolType: ToolType.cutting,
        maxDurability: 40.0,
      ),
      oldOxe = ToolItemMeta(
        "old-oxe",
        toolType: ToolType.oxe,
        toolLevel: ToolLevel.low,
        maxDurability: 30.0,
      )
    ]);
  }
}
