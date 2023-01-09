import 'item.dart';

class Contents {
  static final ItemContents items = ItemContents();

  static ItemMetaProtocol getItemMetaByName(String name) {
    return items[name] ?? const EmptyItemMeta();
  }
}

class ItemContents {
  Map<String, ItemMetaProtocol> name2Item = {};

  ItemMetaProtocol? operator [](String name) => name2Item[name];
}

extension ItemContentsX on ItemContents {
  void operator <<(ItemMetaProtocol item) => name2Item[item.name] = item;

  void addAll(List<ItemMetaProtocol> items) {
    for (final item in items) {
      name2Item[item.name] = item;
    }
  }
}
