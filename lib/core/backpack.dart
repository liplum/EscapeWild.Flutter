import 'package:collection/collection.dart';
import 'package:escape_wild_flutter/utils/collection.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'item.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack {
  @JsonKey(toJson: directConvertFunc)
  List<ItemEntry> items = [];

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);
}

extension BackpackX on Backpack {
  void addItem(ItemEntry item) => items.add(item);

  bool removeItem(ItemEntry item) => items.remove(item);

  void addItems(Iterable<ItemEntry> items) => this.items.addAll(items);

  ItemEntry? getItemByName(String name) => items.firstWhereOrNull((e) => e.name == name);

  bool hasItemOfName(String name) => items.any((e) => e.name == name);

  int countItemOfName(String name) => items.count((e) => e.name == name);

  int countItemWhere(bool Function(ItemEntry) predicate) => items.count(predicate);

  ItemEntry? popItemByName(String name) {
    var removed = getItemByName(name);
    items.remove(removed);
    return removed;
  }

  void removeItemsWhere(bool Function(ItemEntry) predicate) => items.removeWhere(predicate);

  ItemEntry? popItemByType<T>() {
    var removed = items.firstWhereOrNull((e) => e is T);
    items.remove(removed);
    return removed;
  }
}

extension BackpackItemFinderX on Backpack {
  Iterable<CompPair<ToolComp>> findToolsOfType(ToolType toolType) sync* {
    for (final item in items) {
      final asTool = item.tryGetComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        yield CompPair(item, asTool);
      }
    }
  }

  CompPair<ToolComp>? findBestToolOfType(ToolType toolType) {
    return findToolsOfType(toolType).maxOfOrNull((p) => p.comp.toolLevel);
  }
}
