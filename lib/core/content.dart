import 'package:escape_wild_flutter/core/mod.dart';

import 'item.dart';

class Contents {
  static final ItemContents items = ItemContents();
  static final ModContents mods = ModContents();

  static ItemMetaProtocol getItemMetaByName(String name) {
    return items[name] ?? EmptyItemMeta.instance;
  }

  static ModProtocol? getModById(String modId) {
    if (modId == Vanilla.instance.modId) return Vanilla.instance;
    return mods[modId];
  }
}

class ItemContents {
  Map<String, ItemMetaProtocol> name2Item = {};
}

extension ItemContentsX on ItemContents {
  ItemMetaProtocol? operator [](String name) => name2Item[name];

  void operator <<(ItemMetaProtocol item) => name2Item[item.name] = item;

  void addAll(List<ItemMetaProtocol> items) {
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
