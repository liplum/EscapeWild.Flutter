import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack {
  @JsonKey()
  List<ItemEntry> items = [];
  @JsonKey()
  double mass = 0.0;

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);
}

extension BackpackX on Backpack {
  void addItemOrMerge(ItemEntry item) {
    if (item.meta.mergeable) {
      final existed = getItemByIdenticalMeta(item);
      if (existed != null) {
        item.mergeTo(existed);
      } else {
        items.add(item);
      }
    } else {
      items.add(item);
    }
    mass += item.actualMass;
  }

  double sumMass() {
    var sum = 0.0;
    for (final item in items) {
      sum += item.actualMass;
    }
    return sum;
  }

  int get itemCount => items.length;

  ItemEntry operator [](int index) => items[index];

  ItemEntry? getItemByName(String name) => items.firstWhereOrNull((e) => e.meta.name == name);

  ItemEntry? getItemByIdenticalMeta(ItemEntry item) => items.firstWhereOrNull((e) => e.meta == item.meta);

  bool hasItemOfName(String name) => items.any((e) => e.meta.name == name);

  int countItemOfName(String name) => items.count((e) => e.meta.name == name);

  int countItemWhere(bool Function(ItemEntry) predicate) => items.count(predicate);
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
