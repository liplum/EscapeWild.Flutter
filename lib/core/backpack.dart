import 'package:collection/collection.dart';
import 'package:escape_wild_flutter/utils/collection.dart';

import 'item.dart';
import 'player.dart';

class Backpack {
  final Player owner;
  final List<IItem> items;

  const Backpack(this.owner, this.items);
}

extension BackpackX on Backpack {
  void addItem(IItem item) => items.add(item);

  bool removeItem(IItem item) => items.remove(item);

  void addItems(Iterable<IItem> items) => this.items.addAll(items);

  IItem? getItemByName(String name) => items.firstWhereOrNull((e) => e.name == name);

  bool hasItemOfName(String name) => items.any((e) => e.name == name);

  int countItemOfName(String name) => items.count((e) => e.name == name);

  int countItemWhere(bool Function(IItem) predicate) => items.count(predicate);

  IItem? popItemByName(String name) {
    var removed = getItemByName(name);
    items.remove(removed);
    return removed;
  }

  void removeItemsWhere(bool Function(IItem) predicate) => items.removeWhere(predicate);

  IItem? popItemByType<T>() {
    var removed = items.firstWhereOrNull((e) => e is T);
    items.remove(removed);
    return removed;
  }
}
