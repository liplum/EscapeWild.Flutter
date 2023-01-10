import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Tools {
  static late final Item survivalKnife;
  static late final Item oldOxe;
  static late final Item oldFishRod;
  static late final Item bearTrap;
  static late final Item oldShotgun;
  static late final Item catchingNet;

  static void registerAll() {
    // cutting
    Contents.items.addAll([
      survivalKnife = Item("survival-knife").asTool(
        level: ToolLevel.high,
        type: ToolType.cutting,
        maxDurability: 40.0,
      ),
    ]);
    // oxe
    Contents.items.addAll([
      oldOxe = Item("old-oxe").asTool(
        type: ToolType.oxe,
        level: ToolLevel.low,
        maxDurability: 30.0,
      )
    ]);
    // fishing
    Contents.items.addAll([
      oldFishRod = Item("old-fish-rod").asTool(
        type: ToolType.fishing,
        level: ToolLevel.normal,
        maxDurability: 50.0,
      )
    ]);
    // gun
    Contents.items.addAll([
      oldShotgun = Item("old-shotgun").asTool(
        type: ToolType.gun,
        level: ToolLevel.low,
        maxDurability: 50.0,
      )
    ]);
    // trap
    Contents.items.addAll([
      bearTrap = Item("bear-trap").asTool(
        type: ToolType.trap,
        level: ToolLevel.high,
        maxDurability: 30.0,
      )
    ]);
  }
}
