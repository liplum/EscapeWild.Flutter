import 'package:escape_wild/core.dart';

class Tools {
  Tools._();

  static late final Item survivalKnife;
  static late final Item oldAxe, stoneAxe;
  static late final Item oldFishRod;
  static late final Item bearTrap;
  static late final Item oldShotgun;
  static late final Item catchingNet;

  // survival tool
  static late final Item waterFilter;

  // fire starter
  static late final Item handDrillKit;

  // cooker
  static late final Item woodenBowl;

  //light
  static late final Item unlitTorch, litTorch;

  static void registerAll() {
    // cutting
    Contents.items.addAll([
      survivalKnife = Item.unmergeable("survival-knife", mass: 100)
          .asTool(
            attr: ToolAttr.high,
            type: ToolType.cutting,
          )
          .hasDurability(max: 500.0),
    ]);
    // axe
    Contents.items.addAll([
      oldAxe = Item.unmergeable("old-axe", mass: 3000)
          .asTool(type: ToolType.axe, attr: ToolAttr.normal)
          .hasDurability(max: 300.0),
      stoneAxe = Item.unmergeable("stone-axe", mass: 1500)
          .asTool(
            type: ToolType.axe,
            attr: ToolAttr.low,
          )
          .hasDurability(max: 100.0)
    ]);
    // fishing
    Contents.items.addAll([
      oldFishRod = Item.unmergeable("old-fish-rod", mass: 500)
          .asTool(
            type: ToolType.fishing,
            attr: ToolAttr.normal,
          )
          .hasDurability(max: 300.0)
    ]);
    // gun
    Contents.items.addAll([
      oldShotgun = Item.unmergeable("old-shotgun", mass: 3000)
          .asTool(
            type: ToolType.gun,
            attr: ToolAttr.low,
          )
          .hasDurability(max: 300.0)
    ]);
    // trap
    Contents.items.addAll([
      bearTrap = Item.unmergeable("bear-trap", mass: 2000)
          .asTool(
            type: ToolType.trap,
            attr: ToolAttr.high,
          )
          .hasDurability(max: 100.0)
    ]);
    // fire starter
    Contents.items.addAll([
      handDrillKit = Item.unmergeable("hand-drill-kit", mass: 500)
          .hasDurability(max: 200)
          .asFireStarter(chance: 0.3, cost: 20)
          .asFuel(heatValue: 200)
          .tagged(["wooden"]),
    ]);
    // survival tool
    Contents.items.addAll([
      waterFilter = Item.unmergeable("water-filter", mass: 3000).hasDurability(max: 50),
    ]);
    // light
    Contents.items.addAll([
      // cook to ignite it.
      unlitTorch = Item.unmergeable("unlit-torch", mass: 1500).tagged(["cookable"]),
      litTorch = Item.unmergeable("lit-torch", mass: 1500)
          .asTool(type: ToolType.lighting, attr: ToolAttr.normal)
          .hasDurability(max: 1000) // it can last 2 hours
          .continuousModifyDurability(deltaPerMinute: 8, wetFactor: 10),
    ]);
  }
}
