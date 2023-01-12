import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/ecs.dart';
import 'package:escape_wild/core/item.dart';

import 'stuff.dart';

class Foods {
  Foods._();

  // energy food
  static late final Item energyBar, energyDrink;
  static late final Item bugMeat, wetLichen;

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
  static late final Item flowerTea;
  static late final Item rockSalt;
  static late final Item bearMeat, cookedBearMeat, bearExcrement;
  static late final Item reindeerMeat, cookedReindeerMeat;

  static void registerAll() {
    // food
    Contents.items.addAll([
      energyBar = Item.unmergeable("energy-bar", mass: 150).asEatable([
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ]).tagged(["packaged", "food"]),
      bugMeat = Item.mergeable("bug-meat", mass: 10).asEatable([
        Attr.food + 0.1,
        Attr.water + 0.1,
      ]).tagged(["bug", "food"]),
      wetLichen = Item.mergeable("wet-lichen", mass: 10).asEatable([
        Attr.food + 0.05,
        Attr.water + 0.2,
      ]),
      bearExcrement = Item.mergeable("bear-excrement", mass: 666).asEatable([
        Attr.food + 0.06,
      ]),
    ]);
    // water
    Contents.items.addAll([
      bottledWater = Item.unmergeable("bottled-water", mass: 220).asDrinkable([
        Attr.water + 0.28,
      ], afterUsed: () => Stuff.plasticBottle).tagged(["water", "drink", "packaged", "bottle"]),
      dirtyWater = Item.mergeable("dirty-water", mass: 200)
          .asDrinkable([
            Attr.health - 0.085,
            Attr.water + 0.15,
          ])
          .asCookable(CookType.boil, fuelCost: 30, output: () => boiledWater)
          .tagged(["water", "drink"]),
      clearWater = Item.mergeable("clear-water", mass: 200)
          .asDrinkable([
            Attr.health - 0.02,
            Attr.water + 0.18,
          ])
          .asCookable(CookType.boil, fuelCost: 30, output: () => boiledWater)
          .tagged(["water", "drink"]),
      cleanWater = Item.mergeable("clean-water", mass: 200).asDrinkable([
        Attr.water + 0.235,
      ]).tagged(["water", "drink"]),
      boiledWater = Item.mergeable("boiled-water", mass: 200).asDrinkable([
        Attr.water + 0.28,
      ]).tagged(["water", "drink"]),
      filteredWater = Item.mergeable("filtered-water", mass: 200).asDrinkable([
        Attr.health - 0.005,
        Attr.water + 0.2,
      ]).tagged(["water", "drink"]),
      energyDrink = Item.unmergeable("energy-drink", mass: 240).asDrinkable([
        Attr.water + 0.28,
        Attr.energy + 0.12,
      ], afterUsed: () => Stuff.plasticBottle).tagged(["packaged", "water", "drink", "bottle"]),
    ]);
    // cookable
    Contents.items.addAll([
      berry = Item.mergeable("berry", mass: 80)
          .asEatable([
            Attr.food + 0.12,
            Attr.water + 0.06,
          ])
          .asCookable(CookType.roast, fuelCost: 30, output: () => roastedBerry)
          .tagged(["fruit", "food"]),
      roastedBerry = Item.mergeable("roasted-berry", mass: 80).asEatable([
        Attr.food + 0.185,
      ]).tagged(["food"]),
      nuts = Item.mergeable("nuts", mass: 80)
          .asEatable([
            Attr.food + 0.08,
          ])
          .asCookable(CookType.roast, fuelCost: 25, output: () => toastedNuts)
          .tagged(["food"]),
      toastedNuts = Item.mergeable("toasted-nuts", mass: 80).asEatable([
        Attr.food + 0.12,
      ]).tagged(["food"]),
      rawRabbit = Item.mergeable("raw-rabbit", mass: 500)
          .asEatable([
            Attr.food + 0.45,
            Attr.water + 0.05,
          ])
          .asCookable(
            CookType.cook,
            fuelCost: 200,
            output: () => cookedRabbit,
          )
          .tagged(["meat", "raw", "food"]),
      cookedRabbit = Item.mergeable("cooked-rabbit", mass: 500).asEatable([
        Attr.food + 0.68,
      ]).tagged(["meat", "cooked", "food"]),
      rawFish = Item.mergeable("raw-fish", mass: 500)
          .asEatable([
            Attr.food + 0.35,
            Attr.water + 0.08,
          ])
          .asCookable(
            CookType.cook,
            fuelCost: 145,
            output: () => cookedFish,
          )
          .tagged(["fish", "raw", "food"]),
      cookedFish = Item.mergeable("cooked-fish", mass: 500).asEatable([
        Attr.food + 0.52,
      ]).tagged(["fish", "cooked", "food"]),
      flowerTea = Item.mergeable("dandelion-tea", mass: 100).asDrinkable([
        Attr.water + 0.20,
        //After drinking this, the pain caused by constipation will be slightly reduced
      ]),
      rockSalt = Item.mergeable("rock-salt", mass: 10).asEatable([
        Attr.water - 0.3,
        Attr.energy + 0.03,
        //
      ]),
      bearMeat = Item.mergeable("bear-meat", mass: 666)
          .asEatable([Attr.food + 0.1])
          .asCookable(
            CookType.cook,
            fuelCost: 180,
            output: () => cookedBearMeat,
          )
          .tagged(["meat", "raw", "food"]),
      cookedBearMeat = Item.mergeable("cookedBearMeat", mass: 666).asEatable([
        Attr.food + 0.4,
      ]).tagged(["meat", "cooked", "food"]),
    ]);
  }
}
