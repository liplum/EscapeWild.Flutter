import 'package:collection/collection.dart';
import 'package:escape_wild_flutter/utils/collection.dart';

import 'item.dart';
import 'player.dart';

class Backpack {
  final Player owner;
  final List<ItemMetaProtocol> items;

  const Backpack(this.owner, this.items);
}

extension BackpackX on Backpack {
  void addItem(ItemMetaProtocol item) => items.add(item);

  bool removeItem(ItemMetaProtocol item) => items.remove(item);

  void addItems(Iterable<ItemMetaProtocol> items) => this.items.addAll(items);

  ItemMetaProtocol? getItemByName(String name) => items.firstWhereOrNull((e) => e.name == name);

  bool hasItemOfName(String name) => items.any((e) => e.name == name);

  int countItemOfName(String name) => items.count((e) => e.name == name);

  int countItemWhere(bool Function(ItemMetaProtocol) predicate) => items.count(predicate);

  ItemMetaProtocol? popItemByName(String name) {
    var removed = getItemByName(name);
    items.remove(removed);
    return removed;
  }

  void removeItemsWhere(bool Function(ItemMetaProtocol) predicate) => items.removeWhere(predicate);

  ItemMetaProtocol? popItemByType<T>() {
    var removed = items.firstWhereOrNull((e) => e is T);
    items.remove(removed);
    return removed;
  }
}
