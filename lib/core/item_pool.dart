import 'dart:math';

import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/utils.dart';

class ItemPoolEntry {
  final Item item;
  final Ratio chance;

  /// - When [item.mergeable] is true, the [minSize] means the minimum stack size.
  /// - Otherwise, it means the minimum number of item to be generated.
  ///
  /// Inclusive
  final int minSize;

  /// When [item.mergeable] is true, the [maxSize] means the maximum stack size.
  /// - Otherwise, it means the maximum number of item to be generated.
  ///
  /// Exclusive
  final int maxSize;

  const ItemPoolEntry(this.item, this.chance, {required this.minSize, required this.maxSize})
    : assert(minSize <= maxSize);

  const ItemPoolEntry.fixed(this.item, this.chance, {required int size}) : minSize = size, maxSize = size;
}

/// An [ItemPool] is used to randomize loots.
class ItemPool with Moddable {
  @override
  final String name;
  final Set<Item> _items = {};
  final List<ItemPoolEntry> _candidates = [];

  ItemPool(this.name);

  List<ItemStack> randomize(Random rand) {
    assert(_candidates.isNotEmpty, "$registerName is empty.");
    final entry = _candidates[rand.i(0, _candidates.length)];
    final int size;
    if (entry.minSize == entry.maxSize) {
      size = entry.minSize;
    } else {
      size = rand.i(entry.minSize, entry.maxSize);
    }
    if (size <= 0) return const [];
    if (entry.item.mergeable) {
      return [entry.item.create(mass: size)];
    } else {
      return entry.item.repeat(size);
    }
  }
}

extension ItemPoolX on ItemPool {
  ItemPool addItem(ItemPoolEntry entry) {
    _candidates.add(entry);
    _items.add(entry.item);
    return this;
  }
}
