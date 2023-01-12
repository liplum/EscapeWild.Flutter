import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class CraftRecipes {
  CraftRecipes._();

  static void registerAll() {
    Contents.craftRecipes.addAll([
      WetMergeCraftRecipe(
        "tinder",
        CraftRecipeCat.fire,
        inputTags: [
          50.g("flammable-floc"),
        ],
        outputMass: 30,
        output: () => Stuff.tinder,
      ),
      WetMergeCraftRecipe(
        "hand-drill-kit",
        CraftRecipeCat.fire,
        inputTags: [
          50.g("tinder"),
          50.g("sticks"),
          200.g("log"),
        ],
        output: () => Tools.handDrillKit,
      ),
    ]);
  }
}

class WetMergeCraftRecipe extends CraftRecipeProtocol {
  final List<TagMassEntry> inputTags;
  final int? outputMass;
  final ItemGetter<Item> output;

  @override
  List<ItemMatcher> inputSlots = [];

  @override
  List<ItemMatcher> toolSlots = [];

  WetMergeCraftRecipe(
    super.name,
    super.cat, {
    required this.inputTags,
    this.outputMass,
    required this.output,
  }) {
    for (final input in inputTags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(input.tag),
        exact: (item) {
          return item.meta.hasTag(input.tag) && item.actualMass >= (outputMass ?? item.meta.mass);
        },
      ));
    }
  }

  @override
  Item get outputItem => output();

  ItemEntry onCraft(List<ItemEntry> inputs) {
    var sumMass = 0;
    var sumWet = 0.0;
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.tag);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemEntry.empty;
      final inputMass = input.actualMass;
      sumMass += inputMass;
      sumWet += WetComp.tryGetWet(input) * inputMass;
    }
    final res = Stuff.tinder.create(mass: outputMass);
    WetComp.trySetWet(res, sumWet / sumMass);
    return res;
  }
}

extension _DSL on int {
  TagMassEntry g(String tag) {
    return TagMassEntry(tag, this);
  }
}
