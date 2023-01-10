import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

import 'stuff.dart';

class Foods {
  // energy food
  static late final Item energyBar, energyDrink;
  static late final Item longicornLarva, wetLichen;

  // rabbit
  static late final Item rawRabbit, cookedRabbit;

  // fish
  static late final Item rawFish, cookedFish;

  // berry
  static late final Item berry, roastedBerry;

  // nuts
  static late final Item nuts, toastedNuts;

  // water
  static late final Item bottledWater, dirtyWater, cleanWater, boiledWater, filteredWater;

  // tea
  static late final Item dandelionTea;
  static late final Item rockSalt;

  static void registerAll() {
    // food
    Contents.items.addAll([
      energyBar = Item("energy-bar").asEatable([
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ], unit: 150),
      longicornLarva = Item("longicorn-larva").asEatable([
        Attr.food + 0.1,
        Attr.water + 0.1,
      ], unit: 10),
      wetLichen = Item("wet-lichen").asEatable([
        Attr.food + 0.05,
        Attr.water + 0.2,
      ], unit: 10)
    ]);
    // water
    Contents.items.addAll([
      bottledWater = Item.unmergeable("bottled-water", mass: 220).asDrinkable([
        Attr.food + 0.28,
      ], afterUsed: () => Stuff.plasticBottle),
      dirtyWater = Item("dirty-water").asDrinkable([
        Attr.health - 0.085,
        Attr.water + 0.15,
      ], unit: 200).asCookable(CookType.boil, unit: 200, fuelCost: 30, output: () => boiledWater),
      cleanWater = Item("clean-water").asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.235,
      ], unit: 200),
      boiledWater = Item("boiled-water").asDrinkable([
        Attr.water + 0.28,
      ], unit: 200),
      filteredWater = Item("filtered-water").asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.2,
      ], unit: 200),
      energyDrink = Item.unmergeable("energy-drink", mass: 240).asDrinkable([
        Attr.water + 0.28,
        Attr.energy + 0.12,
      ]),
    ]);
    // cookable
    Contents.items.addAll([
      berry = Item("berry").asEatable([
        Attr.food + 0.12,
        Attr.water + 0.06,
      ], unit: 80).asCookable(CookType.roast, unit: 80,fuelCost: 30, output: () => roastedBerry),
      roastedBerry = Item("roasted-berry").asEatable([
        Attr.food + 0.185,
      ], unit: 80),
      nuts = Item("nuts").asEatable([
        Attr.food + 0.08,
      ], unit: 80).asCookable(CookType.roast, unit: 80, fuelCost: 25, output: () => toastedNuts),
      toastedNuts = Item("toasted-nuts").asEatable([
        Attr.food + 0.12,
      ], unit: 80),
      rawRabbit = Item("raw-rabbit").asEatable([
        Attr.food + 0.45,
        Attr.water + 0.05,
      ], unit: 500).asCookable(
        CookType.cook,
        unit: 500,
        fuelCost: 200,
        output: () => cookedRabbit,
      ),
      cookedRabbit = Item("cooked-rabbit").asEatable([
        Attr.food + 0.68,
      ], unit: 500),
      rawFish = Item("raw-fish").asEatable([
        Attr.food + 0.35,
        Attr.water + 0.08,
      ], unit: 500).asCookable(
        CookType.cook,
        unit: 500,
        fuelCost: 145,
        output: () => cookedFish,
      ),
      cookedFish = Item("cooked-fish").asEatable([
        Attr.food + 0.52,
      ], unit: 500),
      dandelionTea = Item("dandelion-tea").asDrinkable([
        Attr.water + 0.20,
        //After drinking this, the pain caused by constipation will be slightly reduced
      ], unit: 100),
      rockSalt = Item("rock-salt").asEatable([
        Attr.water - 0.3,
        Attr.energy + 0.03,
        //
      ], unit: 10),
    ]);
  }
}
