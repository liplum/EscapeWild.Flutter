import 'package:escape_wild/core/craft.dart';
import 'package:escape_wild/core/mod.dart';

import 'item.dart';

class Contents {
  Contents._();

  static final items = ItemContents();
  static final mods = ModContents();
  static final craftRecipes = CraftRecipeContents();

  static Item getItemMetaByName(String name) {
    return items[name] ?? Item.empty;
  }

  static ModProtocol? getModById(String modId) {
    if (modId == Vanilla.instance.modId) return Vanilla.instance;
    return mods[modId];
  }

  static List<CraftRecipeProtocol> getCraftRecipesByCat(CraftRecipeCat cat) {
    return craftRecipes[cat] ?? const [];
  }

  static final Map<ItemMatcher, List<Item>> _matcher2Items = {};

  static List<Item> getMatchedItems(ItemMatcher matcher) {
    var items = _matcher2Items[matcher];
    if (items != null) return items;
    items = <Item>[];
    _matcher2Items[matcher] = items;
    for (final item in Contents.items.name2Item.values) {
      if (matcher.type(item)) {
        items.add(item);
      }
    }
    return items;
  }
}

class ItemContents {
  Map<String, Item> name2Item = {};
}

extension ItemContentsX on ItemContents {
  Item? operator [](String name) => name2Item[name];

  void operator <<(Item item) => name2Item[item.name] = item;

  void addAll(Iterable<Item> items) {
    for (final item in items) {
      name2Item[item.name] = item;
    }
  }
}

class ModContents {
  Map<String, ModProtocol> modId2Mod = {};
}

extension ModContentsX on ModContents {
  ModProtocol? operator [](String name) => modId2Mod[name];
}

class CraftRecipeContents {
  Map<CraftRecipeCat, List<CraftRecipeProtocol>> cat2Recipes = {};
  Map<String, CraftRecipeProtocol> name2Recipe = {};
}

extension CraftRecipeContentsX on CraftRecipeContents {
  List<CraftRecipeProtocol>? operator [](CraftRecipeCat cat) => cat2Recipes[cat];

  void operator <<(CraftRecipeProtocol recipe) {
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
