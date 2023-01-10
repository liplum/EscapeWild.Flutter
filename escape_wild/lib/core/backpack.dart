import 'package:collection/collection.dart';
import 'package:escape_wild/utils/collection.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'item.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack {
  @JsonKey(toJson: directConvertFunc)
  // ignore: prefer_final_fields
  List<ItemEntry> _items = [];

  int get itemCount => _items.length;

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);
}

extension BackpackX on Backpack {
  ItemEntry operator [](int index) => _items[index];

  void addItem(ItemEntry item) => _items.add(item);

  bool removeItem(ItemEntry item) => _items.remove(item);

  void addItems(Iterable<ItemEntry> items) => _items.addAll(items);

  ItemEntry? getItemByName(String name) => _items.firstWhereOrNull((e) => e.name == name);

  bool hasItemOfName(String name) => _items.any((e) => e.name == name);

  int countItemOfName(String name) => _items.count((e) => e.name == name);

  int countItemWhere(bool Function(ItemEntry) predicate) => _items.count(predicate);

  ItemEntry? popItemByName(String name) {
    var removed = getItemByName(name);
    _items.remove(removed);
    return removed;
  }

  void removeItemsWhere(bool Function(ItemEntry) predicate) => _items.removeWhere(predicate);

  ItemEntry? popItemByType<T>() {
    var removed = _items.firstWhereOrNull((e) => e is T);
    _items.remove(removed);
    return removed;
  }
}

extension BackpackItemFinderX on Backpack {
  Iterable<CompPair<ToolComp>> findToolsOfType(ToolType toolType) sync* {
    for (final item in _items) {
      final asTool = item.tryGetComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        yield CompPair(item, asTool);
      }
    }
  }

  CompPair<ToolComp>? findBestToolOfType(ToolType toolType) {
    return findToolsOfType(toolType).maxOfOrNull((p) => p.comp.toolLevel);
  }

  bool hasAnyToolOfTypes(List<ToolType> toolTypes) {
    for (final item in _items) {
      final asTool = item.tryGetComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        return true;
      }
    }
    return false;
  }
}
