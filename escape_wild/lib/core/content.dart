import 'package:escape_wild/core/craft.dart';
import 'package:escape_wild/core/mod.dart';

import 'item.dart';

class Contents {
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
  Map<CraftRecipeCat, List<CraftRecipeProtocol>> cat2Recipe = {};
  Map<String, CraftRecipeProtocol> name2Recipe = {};
}

extension CraftRecipeContentsX on CraftRecipeContents {
  List<CraftRecipeProtocol>? operator [](CraftRecipeCat cat) => cat2Recipe[cat];

  void operator <<(CraftRecipeProtocol recipe) {
    name2Recipe[recipe.name] = recipe;
    var list = cat2Recipe[recipe.cat];
    if (list == null) {
      list = <CraftRecipeProtocol>[];
      cat2Recipe[recipe.cat] = list;
    }
    list.add(recipe);
  }

  void addAll(Iterable<CraftRecipeProtocol> recipes) {
    for (final recipe in recipes) {
      this << recipe;
    }
  }
}
