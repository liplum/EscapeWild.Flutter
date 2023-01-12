import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack with ChangeNotifier {
  @JsonKey()
  List<ItemEntry> items = [];
  @JsonKey()
  int mass = 0;

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);

  void addItemsOrMergeAll(Iterable<ItemEntry> addition) {
    var addedOrMerged = false;
    for (final item in addition) {
      addedOrMerged |= _addItemOrMerge(item);
    }
    if (addedOrMerged) {
      notifyListeners();
    }
  }

  void addItemOrMerge(ItemEntry item) {
    if (_addItemOrMerge(item)) {
      notifyListeners();
    }
  }

  bool removeItem(ItemEntry item) {
    if (item.isEmpty) return true;
    final hasRemoved = items.remove(item);
    if (hasRemoved) {
      mass -= item.actualMass;
    }
    notifyListeners();
    return hasRemoved;
  }

  int indexOfItem(ItemEntry item) {
    if (item.isEmpty) return -1;
    return items.indexOf(item);
  }

  void changeMass(ItemEntry item, int newMass) {
    assert(item.meta.mergeable, "mass of unmergeable can't be changed");
    if (!item.meta.mergeable) return;
    if (newMass <= 0) {
      removeItem(item);
    } else {
      item.mass = newMass;
      notifyListeners();
    }
  }
}

extension ItemEntryListX on List<ItemEntry> {
  void addItemOrMergeAll(List<ItemEntry> additions) {
    for (final addition in additions) {
      addItemOrMerge(addition);
    }
  }

  void addItemOrMerge(ItemEntry addition) {
    var merged = false;
    for (final result in this) {
      if (addition.canMergeTo(result)) {
        addition.mergeTo(result);
        merged = true;
        break;
      }
    }
    if (!merged) {
      add(addition);
    }
  }
}

extension BackpackX on Backpack {
  /// return whether [item] is added or merged.
  bool _addItemOrMerge(ItemEntry item) {
    if (item.isEmpty) return false;
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
    return true;
  }

  double sumMass() {
    var sum = 0.0;
    for (final item in items) {
      sum += item.actualMass;
    }
    return sum;
  }

  ItemEntry? get firstOrNull => items.first;

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

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

  Iterable<ItemCompPair<ToolComp>> findToolsOfTypes(List<ToolType> toolTypes) sync* {
    for (final item in items) {
      final asTool = item.meta.tryGetFirstComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        yield ItemCompPair(item, asTool);
      }
    }
  }

  ItemCompPair<ToolComp>? findBesToolOfType(ToolType toolType) {
    return findToolsOfType(toolType).maxOfOrNull((p) => p.comp.attr);
  }

  ItemCompPair<ToolComp>? findBesToolOfTypes(List<ToolType> toolTypes) {
    return findToolsOfTypes(toolTypes).maxOfOrNull((p) => p.comp.attr);
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

  bool hasAnyToolOfType(ToolType toolType) {
    for (final item in items) {
      final asTool = item.meta.tryGetFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        return true;
      }
    }
    return false;
  }
}
