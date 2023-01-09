import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

import 'stuff.dart';

class Foods {
  static late AttrModifyItemMeta energyBar, bottledWater, longicornLarva,wetLichen;

  static void registerAll() {
    Contents.items.addAll([
      energyBar = AttrModifyItemMeta("energy-bar", UseType.eat, [
        Attr.food + 0.32,
        Attr.energy + 0.1,
      ]),
      bottledWater = AttrModifyItemMeta(
        "bottled-water",
        UseType.drink,
        [
          Attr.food + 0.28,
        ],
        afterUsedItem: () => Stuff.plasticBottle,
      ),
      longicornLarva = AttrModifyItemMeta(
        "longicorn-larva",
        UseType.eat,
        [
          Attr.food + 0.1,
          Attr.water + 0.1,
        ],
      ),
      wetLichen = AttrModifyItemMeta("wet-lichen", UseType.eat, [Attr.food + 0.05,Attr.water+ 0.2])
    ]);
  }
}

/*
 class RawRabbit extends IUsableItem, ICookableItem
{
 double FlueCost => 18;
 static const double DefaultFoodRestore = 0.45;
 static const double DefaultWaterRestore = 0.05;
 double FoodRestore = DefaultFoodRestore;
 double WaterRestore = DefaultWaterRestore;
 @override String get name =>RawRabbit);

 CookType CookType => CookType.Cook;
 @override UseType get useType => UseType.Eat;

 IItem Cook() => new CookedRabbit
{
// add bounce from raw food
FoodRestore = RoastedBerry.DefaultFoodRestore + FoodRestore * 0.15,
};

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(FoodRestore));
  builder.Add(AttrType.Food.WithEffect(WaterRestore));
}
}

 class CookedRabbit extends IUsableItem
{
 static const double DefaultFoodRestore = 0.5;
 double FoodRestore = DefaultFoodRestore;
 @override String get name =>CookedRabbit);
 @override UseType get useType => UseType.Eat;


 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(FoodRestore));
}
}


 class Berry extends IUsableItem, ICookableItem
{
 double FlueCost => 3;
 static const double DefaultFoodRestore = 0.12;
 static const double DefaultWaterRestore = 0.08;
 double FoodRestore = DefaultFoodRestore;
 double WaterRestore = DefaultWaterRestore;
 @override String get name =>Berry);
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(FoodRestore));
  builder.Add(AttrType.Water.WithEffect(WaterRestore));
}

 CookType CookType => CookType.Roast;

 IItem Cook() => new RoastedBerry
{
// add bounce from raw food
FoodRestore = RoastedBerry.DefaultFoodRestore + FoodRestore * 0.2,
};
}

 class RoastedBerry extends IUsableItem
{
 static const double DefaultFoodRestore = 0.14;
 double FoodRestore = DefaultFoodRestore;
 @override String get name =>RoastedBerry);
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(FoodRestore));
}
}

 class DirtyWater extends IUsableItem, ICookableItem
{
 double FlueCost => 3;
 static const double DefaultWaterRestore = 0.15;
 double WaterRestore = DefaultWaterRestore;
 static const double DefaultHealthDelta = -0.08;
 double HealthDelta = DefaultHealthDelta;
 @override String get name =>DirtyWater);
 CookType CookType => CookType.Boil;
 @override UseType get useType => UseType.Drink;

 IItem Cook() => new CleanWater
{
Restore = CleanWater.DefaultRestore + WaterRestore * 0.1,
};


 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Water.WithEffect(WaterRestore));
  builder.Add(AttrType.Health.WithEffect(HealthDelta));
}
}

 class CleanWater extends IUsableItem
{
 static const double DefaultRestore = 0.3;
 double Restore = DefaultRestore;
 @override String get name =>CleanWater);
 @override UseType get useType => UseType.Drink;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Water.WithEffect(Restore));
}
}

 class Nuts extends IUsableItem, ICookableItem
{
 double FlueCost => 3;
 static const double DefaultRestore = 0.08;
 double Restore = DefaultRestore;
 @override String get name =>Nuts);
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(Restore));
}

 CookType CookType => CookType.Roast;

 IItem Cook() => new ToastedNuts
{
Restore = ToastedNuts.DefaultRestore + Restore * 0.3,
};
}

 class ToastedNuts extends IUsableItem
{
 static const double DefaultRestore = 0.1;
 double Restore = DefaultRestore;
 @override String get name =>ToastedNuts);

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(Restore));
}

 @override UseType get useType => UseType.Eat;
}

 class EnergyDrink extends IUsableItem
{
 double WaterRestore = 0.3;
 double EnergyRestore = 0.2;
 @override String get name =>EnergyDrink);
 @override UseType get useType => UseType.Drink;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Water.WithEffect(WaterRestore));
  builder.Add(AttrType.Energy.WithEffect(EnergyRestore));
}
}

 class RawFish extends IUsableItem, ICookableItem
{
 double FlueCost => 12;
 static const double DefaultFoodRestore = 0.35;
 double FoodRestore = DefaultFoodRestore;
 static const double DefaultWaterRestore = 0.1;
 double WaterRestore = DefaultWaterRestore;
 @override String get name =>RawFish);
 CookType CookType => CookType.Cook;
 @override UseType get useType => UseType.Eat;

 IItem Cook() => new CookedFish
{
Restore = CookedFish.DefaultRestore + FoodRestore * 0.2,
};

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(FoodRestore));
  builder.Add(AttrType.Water.WithEffect(WaterRestore));
}
}

 class CookedFish extends IUsableItem
{
 static const double DefaultRestore = 0.35;
 double Restore = DefaultRestore;
 @override String get name =>CookedFish);
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Food.WithEffect(Restore));
}
}

 class UnknownMushrooms extends IUsableItem, ICookableItem
{
 static const double DefaultHpDelta = 0.45;
 double HpDelta = DefaultHpDelta;
 static const double DefaultFoodDelta = 0.15;
 double FoodDelta = DefaultFoodDelta;
 static const double DefaultEnergyDelta = 0.15;
 double EnergyDelta = DefaultEnergyDelta;
 double FlueCost { get; set; } = 2;

 static UnknownMushrooms Poisonous(double ratio) => new UnknownMushrooms
{
HpDelta = -DefaultHpDelta * ratio,
FoodDelta = -DefaultFoodDelta * ratio,
EnergyDelta = -DefaultEnergyDelta * ratio,
FlueCost = 2 * (1 + ratio),
};

 static UnknownMushrooms Safe(double ratio) => new UnknownMushrooms
{
FoodDelta = DefaultFoodDelta * ratio,
EnergyDelta = DefaultEnergyDelta * ratio,
FlueCost = 2 * (1 + ratio),
};

 static UnknownMushrooms Random() => new UnknownMushrooms
{
HpDelta = Rand.double(-0.4, 0.1),
FoodDelta = Rand.double(-0.2, 0.15),
EnergyDelta = Rand.double(-0.15, 0.05),
FlueCost = Rand.double(2, 4),
};

 @override bool DisplayPreview => false;
 @override String get name =>UnknownMushrooms);
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Health.WithEffect(HpDelta));
}

 CookType CookType => CookType.Roast;

 IItem Cook() => new GrilledUnknownMushrooms
{
HpDelta = Math.Abs(HpDelta),
FoodDelta = Math.Abs(FoodDelta),
EnergyDelta = Math.Abs(EnergyDelta),
};
}

 class GrilledUnknownMushrooms extends IUsableItem
{
 double HpDelta;
 double FoodDelta;
 double EnergyDelta;

 @override String get name =>GrilledUnknownMushrooms);

 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder)
{
  builder.Add(AttrType.Health.WithEffect(HpDelta));
  builder.Add(AttrType.Food.WithEffect(FoodDelta));
  builder.Add(AttrType.Energy.WithEffect(EnergyDelta));
}
}

 class CookableItem extends IUsableItem, ICookableItem
{
 CookableItem(String name)
{
  Name = name;
}

 ItemMaker<IItem> Cooked { get; set; }
 AttrModifier[] Modifiers { get; set; } = Array.Empty<AttrModifier>();
 @override String Name { get; }
 @override UseType get useType => UseType.Eat;

 double FlueCost { get; set; }

 @override void BuildAttrModification(AttrModifierBuilder builder) => builder.Add(Modifiers);

 CookType CookType => CookType.Roast;
 IItem Cook() => Cooked();
}

 class CookedItem extends IUsableItem
{
 CookedItem(String name)
{
  Name = name;
}

 AttrModifier[] Modifiers { get; set; } = Array.Empty<AttrModifier>();
 @override String Name { get; }
 @override UseType get useType => UseType.Eat;

 @override void BuildAttrModification(AttrModifierBuilder builder) => builder.Add(Modifiers);
}*/
