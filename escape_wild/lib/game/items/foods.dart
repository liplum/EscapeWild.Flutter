import 'package:escape_wild/core/index.dart';

import 'stuff.dart';

class Foods {
  Foods._();

  // energy food
  static late final Item energyBar, energyDrink;
  static late final Item bugMeat, moss, fat;

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
      energyBar = Item.unmergeable("energy-bar", mass: 50).asEatable([
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ]).tagged(["packaged", "food"]),
      bugMeat = Item.mergeable("bug-meat", mass: 10).asEatable([
        Attr.food + 0.1,
        Attr.water + 0.1,
      ]).tagged(["bug", "food"]),
      moss = Item.mergeable("moss", mass: 20).asEatable([
        Attr.food + 0.01,
        Attr.water + 0.1,
      ]).tagged(["flammable-floc"]),
      bearExcrement = Item.mergeable("bear-excrement", mass: 666).asEatable([
        Attr.food + 0.06,
      ]),
      fat = Item.mergeable("fat", mass: 100).asEatable([
        Attr.food + 0.5,
      ]).tagged(["torch-head"]),
    ]);
    // water
    Contents.items.addAll([
      bottledWater = Item.unmergeable("bottled-water", mass: 220).asDrinkable([
        Attr.water + 0.28,
      ], afterUsed: () => Stuff.plasticBottle).tagged(["water", "drink", "packaged", "bottle"]),
      dirtyWater = Item.mergeable("dirty-water", mass: 200).asDrinkable([
        Attr.health - 0.18,
        Attr.water + 0.16,
      ]).tagged(["water", "drink", "liquid", "cookable"]),
      clearWater = Item.mergeable("clear-water", mass: 200).asDrinkable([
        Attr.health - 0.04,
        Attr.water + 0.18,
      ]).tagged(["water", "drink", "dirty-water", "liquid", "cookable"]),
      cleanWater = Item.mergeable("clean-water", mass: 200).asDrinkable([
        Attr.water + 0.235,
      ]).tagged(["water", "drink", "clean-water", "liquid"]),
      boiledWater = Item.mergeable("boiled-water", mass: 200).asDrinkable([
        Attr.water + 0.28,
      ]).tagged(["water", "drink", "clean-water", "liquid", "cooked"]),
      filteredWater = Item.mergeable("filtered-water", mass: 200).asDrinkable([
        Attr.health - 0.01,
        Attr.water + 0.25,
      ]).tagged(["water", "drink", "liquid"]),
      energyDrink = Item.unmergeable("energy-drink", mass: 240).asDrinkable([
        Attr.energy + 0.12,
        Attr.water + 0.28,
      ], afterUsed: () => Stuff.plasticBottle).tagged(["packaged", "water", "drink", "bottle"]),
    ]);
    // cookable
    Contents.items.addAll([
      berry = Item.mergeable("berry", mass: 80)
          .asEatable([
            Attr.food + 0.12,
            Attr.water + 0.06,
          ])
          .hasFreshness(expire: const Ts.from(day: 5))
          .hasWetness()
          .tagged(["fruit", "food", "cookable", "raw"]),
      roastedBerry = Item.mergeable("roasted-berry", mass: 80)
          .asEatable([
            Attr.food + 0.185,
          ])
          .hasFreshness(expire: const Ts.from(day: 1))
          .hasWetness()
          .tagged(["food", "cooked"]),
      nuts = Item.mergeable("nuts", mass: 80)
          .asEatable([
            Attr.food + 0.08,
          ])
          .hasFreshness(expire: const Ts.from(day: 64))
          .hasWetness()
          .tagged(["food", "cookable", "raw"]),
      toastedNuts = Item.mergeable("toasted-nuts", mass: 80)
          .asEatable([
            Attr.food + 0.12,
          ])
          .hasFreshness(expire: const Ts.from(day: 15))
          .hasWetness()
          .tagged(["food", "cooked"]),
      rawRabbit = Item.mergeable("raw-rabbit", mass: 500)
          .asEatable([
            Attr.food + 0.45,
            Attr.water + 0.05,
          ])
          .hasFreshness(expire: const Ts.from(day: 2, hour: 12))
          .hasWetness()
          .tagged(["meat", "raw", "food", "cookable", "rabbit"]),
      cookedRabbit = Item.mergeable("cooked-rabbit", mass: 500)
          .asEatable([
            Attr.food + 0.68,
          ])
          .hasFreshness(expire: const Ts.from(day: 3, hour: 12))
          .hasWetness()
          .tagged(["meat", "cooked", "food", "rabbit"]),
      rawFish = Item.mergeable("raw-fish", mass: 500)
          .asEatable([
            Attr.food + 0.35,
            Attr.water + 0.08,
          ])
          .hasFreshness(expire: const Ts.from(day: 2, hour: 12))
          .hasWetness()
          .tagged(["fish", "raw", "food", "cookable"]),
      cookedFish = Item.mergeable("cooked-fish", mass: 500)
          .asEatable([
            Attr.food + 0.52,
          ])
          .hasFreshness(expire: const Ts.from(day: 3))
          .hasWetness()
          .tagged(["fish", "cooked", "food"]),
      //After drinking this, the pain caused by constipation will be slightly reduced
      flowerTea = Item.mergeable("flower-tea", mass: 100).asDrinkable([
        Attr.water + 0.20,
      ]),
      rockSalt = Item.mergeable("rock-salt", mass: 10).asEatable([
        Attr.water - 0.3,
      ]),
      bearMeat = Item.mergeable("bear-meat", mass: 500).asEatable([
        Attr.food + 0.5,
        Attr.water + 0.08,
      ]).tagged(
        ["meat", "raw", "food", "cookable"],
      ),
      cookedBearMeat = Item.mergeable("cooked-bear-meat", mass: 500).asEatable([
        Attr.food + 0.60,
      ]).tagged(["meat", "cooked", "food"]),
    ]);
  }
}
