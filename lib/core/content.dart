import 'package:escape_wild/core/index.dart';

class Contents {
  Contents._();

  static final items = ItemContents();
  static final craftRecipes = CraftRecipeContents();
  static final cookRecipes = CookRecipeContents();
  static final hardness = HardnessContents();

  static Item getItemMetaByName(String name) {
    return items[name] ?? Item.empty;
  }

  static CookRecipeProtocol? getCookRecipesByName(String? name) {
    return name == null ? null : cookRecipes[name];
  }

  static List<CraftRecipeProtocol> getCraftRecipesByCat(CraftRecipeCat cat) {
    return craftRecipes[cat] ?? const [];
  }

  static Hardness getHardnessByName(String name) {
    return hardness[name] ?? Hardness.normal;
  }

  static final Map<ItemMatcher, List<Item>> _matcher2Items = {};

  static List<Item> getMatchedItems(ItemMatcher matcher) {
    var items = _matcher2Items[matcher];
    if (items != null) return items;
    items = matcher.filterTypeMatchedItems(Contents.items.name2Item.values).toList();
    return _matcher2Items[matcher] = items;
  }
}

class ItemContents {
  Map<String, Item> name2Item = {};
}

extension ItemContentsX on ItemContents {
  Item? operator [](String name) => name2Item[name];

  void operator <<(Item item) {
    assert(!name2Item.containsKey(item.name), "${item.name} has been registered.");
    name2Item[item.name] = item;
  }

  void addAll(Iterable<Item> items) {
    for (final item in items) {
      this << item;
    }
  }

  List<Item> toList() => name2Item.values.toList();
}

class CraftRecipeContents {
  Map<CraftRecipeCat, List<CraftRecipeProtocol>> cat2Recipes = {};
  Map<String, CraftRecipeProtocol> name2Recipe = {};
}

extension CraftRecipeContentsX on CraftRecipeContents {
  List<CraftRecipeProtocol>? operator [](CraftRecipeCat cat) => cat2Recipes[cat];

  void operator <<(CraftRecipeProtocol recipe) {
    assert(!name2Recipe.containsKey(recipe.name), "${recipe.name} has been registered.");
    name2Recipe[recipe.name] = recipe;
    var list = cat2Recipes[recipe.cat];
    if (list == null) {
      list = <CraftRecipeProtocol>[];
      cat2Recipes[recipe.cat] = list;
    }
    list.add(recipe);
  }

  void addAll(Iterable<CraftRecipeProtocol> recipes) {
    for (final recipe in recipes) {
      this << recipe;
    }
  }
}

class HardnessContents {
  Map<String, Hardness> name2Hardness = {};
}

extension HardnessContentsX on HardnessContents {
  Hardness? operator [](String name) => name2Hardness[name];

  void operator <<(Hardness hardness) {
    assert(!name2Hardness.containsKey(hardness.name), "${hardness.name} has been registered.");

    name2Hardness[hardness.name] = hardness;
  }

  void addAll(Iterable<Hardness> hardnessList) {
    for (final hardness in hardnessList) {
      this << hardness;
    }
  }
}

class ItemPoolContents {
  Map<String, ItemPool> name2Pool = {};
}

extension ItemPoolContentsX on ItemPoolContents {
  ItemPool? operator [](String name) => name2Pool[name];

  void operator <<(ItemPool pool) {
    assert(!name2Pool.containsKey(pool.name), "${pool.name} has been registered.");
    name2Pool[pool.name] = pool;
  }

  void addAll(Iterable<ItemPool> poolList) {
    for (final name2Pool in poolList) {
      this << name2Pool;
    }
  }
}

class CookRecipeContents {
  Map<String, CookRecipeProtocol> name2FoodRecipe = {};
}

extension FoodRecipeContentsX on CookRecipeContents {
  CookRecipeProtocol? operator [](String name) => name2FoodRecipe[name];

  void operator <<(CookRecipeProtocol recipe) {
    assert(!name2FoodRecipe.containsKey(recipe.name), "${recipe.name} has been registered.");
    name2FoodRecipe[recipe.name] = recipe;
  }

  void addAll(Iterable<CookRecipeProtocol> recipes) {
    for (final recipe in recipes) {
      this << recipe;
    }
  }
}
