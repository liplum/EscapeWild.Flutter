import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../ecs/ecs.dart';
import '../content.dart';
import '../ecs/clone.dart';
import '../ecs/extra.dart';
import '../ecs/extra.new.dart';
import '../time.dart';
import 'item.dart';

@immutable
class ItemStackNew implements Cloneable<ItemStackNew>, JConvertibleProtocol {
  static final empty = ItemStackNew(meta: Item.empty, id: -1);

  static const type = "ItemStack";

  @override
  String get typeName => type;
  final int id;

  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: Item.getName)
  final Item meta;

  @JsonKey(includeIfNull: false)
  final int? mass;

  final ItemCompStore compStore;

  int get stackMass => mass ?? meta.mass;

  static int autoId() => const Uuid().v4().hashCode;

  ItemStackNew({
    required this.meta,
    int? id,
    this.mass,
    this.compStore = ItemCompStore.empty,
  }) : id = id ?? autoId();

  ItemStackNew.mergeable({
    required this.meta,
    int? id,
    required int this.mass,
    this.compStore = ItemCompStore.empty,
  }) : id = id ?? autoId();

  ItemStackNew.unmergeable({
    required this.meta,
    int? id,
    this.compStore = ItemCompStore.empty,
  })  : id = id ?? autoId(),
        mass = null;

  /// Merge this to [target].
  /// - [target.stackMass] will be increased.
  /// - This [stackMass] will be clear.
  ///
  /// Please call [Backpack.addItemOrMerge] to track changes, such as [Backpack.mass].
  ItemStackNew merge(ItemStackNew other) {
    if (!hasIdenticalMeta(other)) {
      throw Exception("Can't merge ${meta.name} with ${other.meta.name}.");
    }
    if (!meta.mergeable) {
      throw Exception("${meta.name} is not mergeable.");
    }
    // handle components
    var newCompStore = compStore;
    for (final comp in meta.iterateComps()) {
      newCompStore = comp.merge(
        (store: newCompStore, mass: stackMass),
        (store: other.compStore, mass: other.stackMass),
      );
    }
    return ItemStackNew(
      meta: meta,
      mass: stackMass + other.stackMass,
      compStore: newCompStore,
    );
  }

  /// Split a part of this, and return the part.
  /// - This [stackMass] will be decreased.
  ///
  /// Please call [Backpack.splitItemInBackpack] to track changes, such as [Backpack.mass].
  /// ```dart
  /// if(canSplit)
  ///   mass = actualMass - massOfPart;
  /// ```
  ({ItemStackNew rest, ItemStackNew part}) split(int massOfPart) {
    if (!canSplit) {
      throw Exception("${meta.name} can't be split.");
    }
    if (massOfPart < 0) {
      throw Exception("`mass` to split must be more than 0");
    }
    if (massOfPart == 0) return (rest: this, part: empty);
    if (stackMass < massOfPart) {
      throw Exception("Self `mass` must be more than `mass` to split.");
    }
    if (stackMass == massOfPart) return (rest: empty, part: this);
    var restCompStore = compStore;
    // handle components
    for (final comp in meta.iterateComps()) {
      (rest: restCompStore, part: _) = comp.split(
        (store: restCompStore, mass: stackMass),
        massOfPart,
      );
    }

    return (
      rest: ItemStackNew(
        meta: meta,
        mass: stackMass - massOfPart,
        compStore: compStore,
      ),
      part: ItemStackNew(
        meta: meta,
        mass: massOfPart,
        compStore: compStore,
      )
    );
  }

  Future<void> onPassTime(Ts delta) async {
    for (final comp in meta.iterateComps()) {
      await comp.onPassTime(this, delta);
    }
  }

  void buildStatus(ItemStackStatusBuilder builder) {
    for (final comp in meta.iterateComps()) {
      comp.buildStatus(this, builder);
    }
  }

  @override
  ItemStackNew clone() {
    return ItemStackNew(
      meta: meta,
      mass: mass,
      id: id,
      compStore: compStore,
    );
  }

  factory ItemStackNew.fromJson(Map<String, dynamic> json) => _$ItemStackFromJson(json);

  Map<String, dynamic> toJson() => _$ItemStackToJson(this);

  String displayName() => meta.l10nName();

  bool hasIdenticalMeta(ItemStackNew other) => meta == other.meta;

  bool conformTo(Item meta) => this.meta == meta;

  bool get canSplit => meta.mergeable;

  bool get canMerge => meta.mergeable;

  bool get isEmpty => identical(this, empty) || meta == Item.empty || stackMass <= 0;

  @override
  String toString() {
    final m = mass;
    final name = meta.l10nName();
    if (m == null) {
      return name;
    } else {
      return "$name ${m.toStringAsFixed(1)}g";
    }
  }
}

extension type const ItemCompStoreEntry(Map<String, dynamic> _store) {

}

extension type const ItemCompStore(Map<String, dynamic> _store) {
  static const empty = ItemCompStore(<String, dynamic>{});

  static String _buildKey(Comp comp, String key) => "${comp.name}.$key";

  T? getValue<T>(Comp comp, String key) {
    final value = _store[_buildKey(comp, key)];
    if (value is T) {
      return value;
    }
    return null;
  }

  ItemCompStore setValue<T>(Comp comp, String key, T? value) {
    if (!(value == null || value is String || value is int || value is double || value is bool)) {
      throw Exception("$value has an unsupported type ${value.runtimeType} for $ItemCompStore");
    }
    final fullKey = _buildKey(comp, key);
    if (value == null) {
      if (_store.containsKey(fullKey)) {
        final newStore = {..._store};
        newStore.remove(fullKey);
        return ItemCompStore(newStore);
      } else {
        return this;
      }
    } else {
      final newStore = {
        ..._store,
        fullKey: value,
      };
      return ItemCompStore(newStore);
    }
  }

  factory ItemCompStore.fromJson(Map<String, dynamic> json) => ItemCompStore(json);

  Map<String, dynamic> toJson() => _store;
}
