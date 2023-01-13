import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack with ChangeNotifier implements JConvertibleProtocol {
  @JsonKey()
  List<ItemEntry> items = [];
  @JsonKey()
  int mass = 0;

  Backpack();

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);

  /// Return the part of [item].
  /// - If the [item] is unmergeable, [ItemEntry.empty] will be returned.
  /// - If the [massOfPart] is more than or equal to [item.mass],
  ///   the [item] will be removed in backpack, and [item] itself will be returned.
  /// - If the [massOfPart] is less than 0, the [ItemEntry.empty] will be returned.
  ItemEntry splitItemInBackpack(ItemEntry item, int massOfPart) {
    assert(item.meta.mergeable, "${item.meta.name} can't split, because it's unmergeable");
    if (!item.meta.mergeable) return ItemEntry.empty;
    final actualMass = item.actualMass;
    if (massOfPart <= 0) {
      return ItemEntry.empty;
    }
    if (massOfPart >= actualMass) {
      removeItem(item);
      return item;
    } else {
      final part = item.split(massOfPart);
      if (part.isNotEmpty) {
        mass -= massOfPart;
        notifyListeners();
      }
      return part;
    }
  }

  void consumeItemInBackpack(ItemEntry item, int? mass) {
    if (mass != null) {
      splitItemInBackpack(item, mass);
    } else {
      removeItem(item);
    }
  }

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

  /// It will remove the [item] in backpack, and won't change [item]'s state.
  bool removeItem(ItemEntry item) {
    if (item.isEmpty) return true;
    final hasRemoved = items.remove(item);
    if (hasRemoved) {
      mass -= item.actualMass;
      notifyListeners();
    }
    return hasRemoved;
  }

  int indexOfItem(ItemEntry item) {
    if (item.isEmpty) return -1;
    return items.indexOf(item);
  }

  /// It will directly change the mass of item and track [Backpack.mass] without calling [ItemComp.onSplit],
  /// It won't update the components.
  void changeMass(ItemEntry item, int newMass) {
    assert(item.meta.mergeable, "mass of unmergeable can't be changed");
    if (!item.meta.mergeable) return;
    if (newMass <= 0) {
      removeItem(item);
    } else {
      final delta = item.actualMass - newMass;
      item.mass = newMass;
      mass -= delta;
      notifyListeners();
    }
  }

  static const type = "Backpack";

  @override
  String get typeName => type;
}

extension BackpackX on Backpack {
  List<ItemEntry> matchItemsWithType(ItemMatcher matcher) {
    return matcher.filterTypedMatchedEntries(items).toList();
  }

  List<ItemEntry> matchExactItems(ItemMatcher matcher) {
    return matcher.filterExactMatchedEntries(items).toList();
  }

  MapEntry<List<ItemEntry>, List<ItemEntry>> splitMatchedAndUnmatched(
    ItemMatcher matcher, {
    bool exact = true,
  }) {
    final matched = <ItemEntry>[];
    final unmatched = <ItemEntry>[];
    for (final item in items) {
      if (exact ? matcher.exact(item) : matcher.typeOnly(item.meta)) {
        matched.add(item);
      } else {
        unmatched.add(item);
      }
    }
    return MapEntry(matched, unmatched);
  }

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
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        yield ItemCompPair(item, asTool);
      }
    }
  }

  Iterable<ItemCompPair<ToolComp>> findToolsOfTypes(List<ToolType> toolTypes) sync* {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
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
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        return true;
      }
    }
    return false;
  }

  bool hasAnyToolOfType(ToolType toolType) {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        return true;
      }
    }
    return false;
  }
}
