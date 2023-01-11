import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

import 'stuff.dart';

class Foods {
  Foods._();

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
  static late final Item bottledWater, dirtyWater, clearWater, cleanWater, boiledWater, filteredWater;

  // tea
  static late final Item dandelionTea;
  static late final Item rockSalt;

  static void registerAll() {
    // food
    Contents.items.addAll([
      energyBar = Item.mergeable("energy-bar", mass: 150).asEatable([
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ]),
      longicornLarva = Item.mergeable("longicorn-larva", mass: 10).asEatable([
        Attr.food + 0.1,
        Attr.water + 0.1,
      ]),
      wetLichen = Item.mergeable("wet-lichen", mass: 10).asEatable([
        Attr.food + 0.05,
        Attr.water + 0.2,
      ])
    ]);
    // water
    Contents.items.addAll([
      bottledWater = Item.unmergeable("bottled-water", mass: 220).asDrinkable([
        Attr.food + 0.28,
      ], afterUsed: () => Stuff.plasticBottle),
      dirtyWater = Item.mergeable("dirty-water", mass: 200).asDrinkable([
        Attr.health - 0.085,
        Attr.water + 0.15,
      ]).asCookable(CookType.boil, unit: 200, fuelCost: 30, output: () => boiledWater),
      clearWater = Item.mergeable("clear-water", mass: 200).asDrinkable([
        Attr.health - 0.02,
        Attr.water + 0.18,
      ]).asCookable(CookType.boil, unit: 200, fuelCost: 30, output: () => boiledWater),
      cleanWater = Item.mergeable("clean-water", mass: 200).asDrinkable([
        Attr.water + 0.235,
      ]),
      boiledWater = Item.mergeable("boiled-water", mass: 200).asDrinkable([
        Attr.water + 0.28,
      ]),
      filteredWater = Item.mergeable("filtered-water", mass: 200).asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.2,
      ]),
      energyDrink = Item.unmergeable("energy-drink", mass: 240).asDrinkable([
        Attr.water + 0.28,
        Attr.energy + 0.12,
      ]),
    ]);
    // cookable
    Contents.items.addAll([
      berry = Item.mergeable("berry", mass: 80).asEatable([
        Attr.food + 0.12,
        Attr.water + 0.06,
      ]).asCookable(CookType.roast, unit: 80, fuelCost: 30, output: () => roastedBerry),
      roastedBerry = Item.mergeable("roasted-berry", mass: 80).asEatable([
        Attr.food + 0.185,
      ]),
      nuts = Item.mergeable("nuts", mass: 80).asEatable([
        Attr.food + 0.08,
      ]).asCookable(CookType.roast, unit: 80, fuelCost: 25, output: () => toastedNuts),
      toastedNuts = Item.mergeable("toasted-nuts", mass: 80).asEatable([
        Attr.food + 0.12,
      ]),
      rawRabbit = Item.mergeable("raw-rabbit", mass: 500).asEatable([
        Attr.food + 0.45,
        Attr.water + 0.05,
      ]).asCookable(
        CookType.cook,
        unit: 500,
        fuelCost: 200,
        output: () => cookedRabbit,
      ),
      cookedRabbit = Item.mergeable("cooked-rabbit", mass: 500).asEatable([
        Attr.food + 0.68,
      ]),
      rawFish = Item.mergeable("raw-fish", mass: 500).asEatable([
        Attr.food + 0.35,
        Attr.water + 0.08,
      ]).asCookable(
        CookType.cook,
        unit: 500,
        fuelCost: 145,
        output: () => cookedFish,
      ),
      cookedFish = Item.mergeable("cooked-fish", mass: 500).asEatable([
        Attr.food + 0.52,
      ]),
      dandelionTea = Item.mergeable("dandelion-tea", mass: 100).asDrinkable([
        Attr.water + 0.20,
        //After drinking this, the pain caused by constipation will be slightly reduced
      ]),
      rockSalt = Item.mergeable("rock-salt", mass: 10).asEatable([
        Attr.water - 0.3,
        Attr.energy + 0.03,
        //
      ]),
    ]);
  }
}
