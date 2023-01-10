import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack {
  List<ItemEntry> items = [];

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);
}

extension BackpackX on Backpack {
  double sumMass() {
    var sum = 0.0;
    for (final item in items) {
      final mass = item.tryGetActualMass();
      if (mass != null) {
        sum += mass;
      }
    }
    return sum;
  }

  int get itemCount => items.length;

  ItemEntry operator [](int index) => items[index];

  void addItem(ItemEntry item) => items.add(item);

  bool removeItem(ItemEntry item) => items.remove(item);

  void addItems(Iterable<ItemEntry> more) => items.addAll(more);

  ItemEntry? getItemByName(String name) => items.firstWhereOrNull((e) => e.meta.name == name);

  bool hasItemOfName(String name) => items.any((e) => e.meta.name == name);

  int countItemOfName(String name) => items.count((e) => e.meta.name == name);

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
  Iterable<ItemCompPair<ToolComp>> findToolsOfType(ToolType toolType) sync* {
    for (final item in items) {
      final asTool = item.meta.tryGetFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        yield ItemCompPair(item, asTool);
      }
    }
  }

  ItemCompPair<ToolComp>? findBestToolOfType(ToolType toolType) {
    return findToolsOfType(toolType).maxOfOrNull((p) => p.comp.toolLevel);
  }

  bool hasAnyToolOfTypes(List<ToolType> toolTypes) {
    for (final item in items) {
      final asTool = item.meta.tryGetFirstComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        return true;
      }
    }
    return false;
  }
}
