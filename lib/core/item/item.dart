import 'dart:math';
import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/r.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'item.g.dart';

typedef ItemGetter = Item Function();

const itemGetterJsonKey = JsonKey(fromJson: NamedItemGetter.create);

class NamedItemGetter {
  final String name;

  const NamedItemGetter(this.name);

  static ItemGetter create(String name) => NamedItemGetter(name).get;

  Item get() => Contents.getItemMetaByName(name);
}

extension NamedItemGetterX on String {
  ItemGetter getAsItem() => NamedItemGetter.create(this);
}

/// # Item
/// Item has a default tag, that's the [name].
///
/// ## When [mergeable] is false
/// It means the item is unmergeable, and [mass] is for one ItemStack.
/// ### Example
/// [mass] of `Tinned Tomatoes` is 500. So each ItemStack takes 500g room in backpack.
/// When player eat or cook it, if possible, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply full changes.
///
/// ## When [mergeable] is true
/// It means the item is mergeable, and [mass] is the unit for each ItemStack.
/// ### Example
/// [mass] of `Berry` is 10. However, ItemStack doesn't care that, it could have an independent [ItemStack.mass] instead.
/// When player eat or cook it, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply changes based [ItemStack.mass].
/// If [ItemStack.mass] is 25, and player has eaten 15g, then [ModifyAttrComp.modifiers] will apply `(15.0 / 10.0) * modifier`.
///
/// ## When [isContainer] is true
/// It means the item is a container, and [mass] stands for the weight of container itself.
///
class Item with TagsMixin, CompMixin<ItemComp> {
  static final empty = Item("empty", mergeable: true, mass: 0);
  final String name;

  /// Unit: [g] gram.
  ///
  /// [mass] > 0
  final int mass;
  final bool mergeable;

  /// If this item [isContainer], it must not be [mergeable].
  bool get isContainer => containerComp != null;

  /// How much can this container hold.
  ContainerCompProtocol? containerComp;

  void _addSelfNameTag() {
    tags.add(name);
  }

  Item(this.name, {required this.mergeable, required this.mass}) {
    assert(mergeable != isContainer, "`mergeable` and `isContainer` are conflict.");
    _addSelfNameTag();
  }

  Item.unmergeable(this.name, {required this.mass}) : mergeable = false, assert(mass > 0) {
    _addSelfNameTag();
  }

  Item.mergeable(this.name, {required this.mass}) : mergeable = true {
    _addSelfNameTag();
  }

  Item.container(this.name, {required this.mass, Iterable<String>? acceptTags, int? capacity, bool? mergeablity})
    : mergeable = false {
    _addSelfNameTag();
    final comp = ContainerComp(acceptTags: acceptTags, capacity: capacity, mergeablity: mergeablity);
    comp.validateItemConfig(this);
    containerComp = comp;
  }

  Item self() => this;

  String l10nName() => i18n("item.$name.name");

  String l10nDescription() => i18n("item.$name.desc");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Item || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  static String getName(Item item) => item.name;
}

extension ItemX on Item {
  ItemStack create({int? mass, double? massF}) {
    if (mergeable) {
      if (mass != null) {
        return ItemStack(this, mass: mass);
      }
      if (massF != null) {
        return ItemStack(this, mass: (this.mass * massF).toInt());
      }
      // If the `ItemStack.mass` is not specified, use `Item.mass`.
      return ItemStack(this, mass: this.mass);
    } else {
      assert(mass == null && massF == null, "`mass` and `massFactor` should be both null for unmergeable");
      return ItemStack(this);
    }
  }

  List<ItemStack> repeat(int number) {
    assert(number > 0, "`number` should be over than 0.");
    assert(!mergeable, "only unmergeable can be generated repeatedly, but $name is given.");
    if (mergeable) {
      // For mergeable, it will multiply the mass.
      return [ItemStack(this, mass: mass * number)];
    } else {
      return List.generate(number.abs(), (i) => ItemStack(this));
    }
  }
}

/// [ContainerCompProtocol] is a special component.
///
/// [Item] can have ot most one [ContainerCompProtocol].
/// If so, the item becomes a container, and its associated [ItemStack] is [ContainerItemStack].
///
/// Nested container is forbidden.
abstract class ContainerCompProtocol {
  const ContainerCompProtocol();

  void validateItemConfig(Item item) {}

  /// Return whether [container] maybe accept [outer].
  ///
  /// The implementation should take those into account:
  /// - Whether [container] is too full to hold more.
  /// - Whether [container] has a different type of inner other than [outer]'s
  /// - Whether [outer] is another container.
  /// - And more...
  bool checkPossibleAccept(ContainerItemStack container, ItemStack outer);

  /// Return the part of [outer] that [container] is accepted.
  /// - [ItemStack] should be checked before in [checkPossibleAccept] and prepare to be split.
  /// - [ItemStack.empty] will be returned if [container] doesn't accept [outer] at all.
  /// - If [container] accepts [outer], [outer.stackMass] will be decreased.
  ItemStack splitAcceptedPart(ContainerItemStack container, ItemStack outer);

  /// When [container] accepts [outer].
  ///
  /// The implementation should handle something like blow:
  /// - Increment [container.innerMass].
  /// - Merge all components
  /// - And more...
  void onAccept(ContainerItemStack container, ItemStack outer);
}

class ContainerComp extends ContainerCompProtocol {
  /// - If [acceptTags] is not null, container will only allow item which matches all tags.
  final Iterable<String>? acceptTags;

  /// - If [capacity] is null, how much item container can hold is unlimited.
  /// - Otherwise, the [ContainerItemStack.innerMass] can't exceed it.
  final int? capacity;

  /// If [mergeablity] is not null, the [Item.mergeable] must match it.
  /// - When [mergeablity] is false, topping up is disallowed.
  ///   In other words, the whole container will be exclusive until [ContainerItemStack.inner] is empty.
  /// - When [mergeablity] is true, topping up is allowed, but the overflowing part will be ignored.
  final bool? mergeablity;

  const ContainerComp({this.acceptTags, this.capacity, this.mergeablity});

  const ContainerComp.limitCapacity(this.capacity, this.mergeablity) : acceptTags = null;

  const ContainerComp.limitTags(this.acceptTags, this.mergeablity) : capacity = null;

  const ContainerComp.unlimited() : this();

  @override
  bool checkPossibleAccept(ContainerItemStack container, ItemStack outer) {
    if (outer.meta.isContainer) return false;
    final inner = container.inner;
    if (inner == null) {
      // container is empty
      // check if outer meets each condition
      if (mergeablity != null && mergeablity != outer.meta.mergeable) return false;
      final acceptTags = this.acceptTags;
      if (acceptTags != null && !outer.meta.hasTags(acceptTags)) return false;
      final capacity = this.capacity;
      if (capacity != null && capacity < outer.stackMass) return false;
    } else {
      // container has item
      // only allow mergeable
      if (!outer.meta.mergeable) return false;
      // only accept the same item
      if (!inner.hasIdenticalMeta(outer)) return false;
      // check if outer meets each condition
      if (mergeablity != null && mergeablity != outer.meta.mergeable) return false;
      final acceptTags = this.acceptTags;
      if (acceptTags != null && !outer.meta.hasTags(acceptTags)) return false;
      // check overflowing
      final capacity = this.capacity;
      if (capacity != null) {
        // container is full
        if (container.innerMass >= capacity) return false;
        // otherwise, container has some room for [outer]
      }
    }
    // Pass all tests!
    return true;
  }

  @override
  ItemStack splitAcceptedPart(ContainerItemStack container, ItemStack outer) {
    final capacity = this.capacity;
    var acceptedMass = outer.stackMass;
    if (capacity != null) {
      final containerRemainingRoom = min(0, capacity - container.innerMass);
      acceptedMass = min(outer.stackMass, containerRemainingRoom);
    }
    final part = outer.split(acceptedMass);
    return part;
  }

  @override
  void onAccept(ContainerItemStack container, ItemStack outer) {
    final inner = container.inner;
    if (inner == null) {
      container.inner = outer;
    } else {
      outer.mergeTo(inner);
    }
  }

  @override
  void validateItemConfig(Item item) {
    final mergeablity = this.mergeablity;
    if (mergeablity != null && mergeablity != item.mergeable) {
      throw ItemMergeableCompConflictError(
        "ContainerComp's mergeablity is not null but different from [item.mergeable].",
        item,
        mergeableShouldBe: mergeablity,
      );
    }
    // The [item.tags] might be not yet initialized, so ignore it.
  }
}

extension ContainerCompX on Item {
  Item asContainer({Iterable<String>? acceptTags, int? capacity, bool? mergeablity}) {
    final comp = ContainerComp(acceptTags: acceptTags, capacity: capacity, mergeablity: mergeablity);
    comp.validateItemConfig(this);
    containerComp = comp;
    return this;
  }
}

class ItemMergeableCompConflictError implements Exception {
  final String message;
  final Item item;
  final bool mergeableShouldBe;

  const ItemMergeableCompConflictError(this.message, this.item, {required this.mergeableShouldBe});

  @override
  String toString() => "[${item.name}]$message. [Item.mergeable] should be $mergeableShouldBe.";
}

class ItemCompConflictError implements Exception {
  final String message;
  final Item item;

  const ItemCompConflictError(this.message, this.item);
}

abstract class ItemComp extends Comp {
  const ItemComp();

  void validateItemConfig(Item item) {}

  /// ## preconditions:
  /// - The [ItemStack.mass] of [from] and [to] are not changed.
  /// ## contrarians:
  /// - Implementation mustn't change [ItemStack.mass].
  void onMerge(ItemStack from, ItemStack to) {}

  /// ## preconditions:
  /// - The [ItemStack.mass] of [from] and [to] are not changed.
  /// - [to] has an [Item.extra] clone from [from].
  /// ## contrarians:
  /// - Implementation mustn't change [ItemStack.mass].
  void onSplit(ItemStack from, ItemStack to) {}

  Future<void> onPassTime(ItemStack stack, Ts delta) async {}

  void buildStatus(ItemStack stack, ItemStackStatusBuilder builder) {}
}

extension ItemCompDebugX on ItemComp {
  /// validate item if debug mode
  void validateItemConfigIfDebug(Item item) {
    if (R.debugMode) {
      validateItemConfig(item);
    }
  }
}

class EmptyComp extends ItemComp {
  static const type = "Empty";

  @override
  String get typeName => type;
}

class ItemCompPair<T extends Comp> {
  final ItemStack stack;
  final T comp;

  const ItemCompPair(this.stack, this.comp);
}

@JsonSerializable()
@CopyWith(skipFields: true)
// @immutable
class ItemStack with ExtraMixin implements JConvertibleProtocol {
  static final empty = ItemStack(.empty, id: -1);
  final int id;

  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: Item.getName)
  final Item meta;

  /// [trackId] is used for backpack tracking and locating this item.
  /// - When backpack starts to track this item, [trackId] is not null.
  /// - When backpack loses track, [trackId] should be null.
  ///
  /// see [Backpack.tracked]
  // @JsonKey(name: "id", includeIfNull: true)
  // int? trackId;

  @JsonKey(includeIfNull: false)
  int? mass;

  int get stackMass => mass ?? meta.mass;

  ItemStack(this.meta, {int? id, this.mass}) : id = id ?? const Uuid().v7().hashCode;

  String displayName() => meta.l10nName();

  bool hasIdenticalMeta(ItemStack other) => meta == other.meta;

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

  /// Merge this to [target].
  /// - [target.stackMass] will be increased.
  /// - This [stackMass] will be clear.
  ///
  /// Please call [Backpack.addItemOrMerge] to track changes, such as [Backpack.mass].
  void mergeTo(ItemStack target) {
    assert(meta.mergeable, "${meta.name} is not mergeable.");
    if (!meta.mergeable) return;
    assert(hasIdenticalMeta(target), "Can't merge ${meta.name} with ${target.meta.name}.");
    if (!hasIdenticalMeta(target)) return;
    final selfMass = stackMass;
    final toMass = target.stackMass;
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onMerge(this, target);
    }
    target.mass = selfMass + toMass;
    mass = 0;
  }

  /// Split a part of this, and return the part.
  /// - This [stackMass] will be decreased.
  ///
  /// Please call [Backpack.splitItemInBackpack] to track changes, such as [Backpack.mass].
  /// ```dart
  /// if(canSplit)
  ///   mass = actualMass - massOfPart;
  /// ```
  ItemStack split(int massOfPart) {
    assert(massOfPart > 0, "`mass` to split must be more than 0");
    if (massOfPart <= 0) return .empty;
    assert(stackMass >= massOfPart, "Self `mass` must be more than `mass` to split.");
    if (stackMass < massOfPart) return .empty;
    assert(canSplit, "${meta.name} can't be split.");
    if (!canSplit) return .empty;
    final selfMass = stackMass;
    // if self mass is less than or equal to mass to split, return a clone.
    if (selfMass <= massOfPart) return clone();
    final part = ItemStack(meta, mass: massOfPart);
    // clone extra
    part.extra = cloneExtra();
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onSplit(this, part);
    }
    mass = selfMass - massOfPart;
    return part;
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

  ItemStack clone() {
    final cloned = ItemStack(meta, mass: mass);
    cloned.extra = cloneExtra();
    return cloned;
  }

  factory ItemStack.fromJson(Map<String, dynamic> json) => _$ItemStackFromJson(json);

  Map<String, dynamic> toJson() => _$ItemStackToJson(this);

  static const type = "ItemStack";

  @override
  String get typeName => type;
}

@JsonSerializable()
class ContainerItemStack extends ItemStack {
  @JsonKey(includeIfNull: false)
  ItemStack? inner;

  @override
  set mass(int? newMass) {
    assert(false, "ContainerItemStack's mass can't be changed.");
  }

  /// [stackMass] is the sum of container and [inner].
  @override
  int get stackMass => innerMass + meta.mass;

  int get innerMass => inner?.stackMass ?? 0;

  ContainerItemStack(super.meta) {
    assert(meta.isContainer, "ContainerItemStack requires [item] to be a container.");
  }

  bool get containsItem => inner?.isNotEmpty != true;

  @override
  String displayName() {
    final inner = this.inner;
    if (inner == null) {
      return meta.l10nName();
    } else {
      return "${meta.l10nName()}[${inner.displayName()}]";
    }
  }

  /// The container itself can't be merged.
  @override
  bool get canMerge => false;

  /// The container itself can't be split.
  @override
  bool get canSplit => false;

  /// The container itself can't be merge.
  @override
  void mergeTo(ItemStack to) {}

  /// The container itself can't be split.
  @override
  ItemStack split(int massOfPart) {
    return this;
  }

  factory ContainerItemStack.fromJson(Map<String, dynamic> json) => _$ContainerItemStackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContainerItemStackToJson(this);

  static const type = "ContainerItemStack";

  @override
  String get typeName => type;
}

extension ItemStackX on ItemStack {
  /// [massMultiplier] is always 1.0 when [Item.mergeable] is true.
  double get massMultiplier => meta.mergeable ? stackMass / meta.mass : 1.0;

  bool canMergeTo(ItemStack to) {
    return hasIdenticalMeta(to) && meta.mergeable;
  }

  bool get isNotEmpty => !isEmpty;
}

class ItemStackStatus {
  final String name;
  final Color? color;

  const ItemStackStatus({required this.name, this.color});
}

class ItemStackStatusBuilder {
  List<ItemStackStatus> statuses = [];
  final bool darkMode;

  ItemStackStatusBuilder({this.darkMode = false});

  void add(ItemStackStatus status) {
    statuses.add(status);
  }

  List<ItemStackStatus> build() {
    return statuses;
  }
}

class StatusColorPreset {
  static const good = Color(0XFFAED581),
      goodDark = Color(0xFF558B2F),
      normal = Color(0xFFFFEB3B),
      normalDark = Color(0xFF9e8e00),
      warning = Color(0xFFFFB74D),
      warningDark = Color(0xFFE65100),
      worst = Color(0xFFEF9A9A),
      worstDark = Color(0xFFC62828);
  static const wet = Color(0xFF29B6F6), wetDark = Color(0xFF1565C0);
}

extension ItemStackStatusBuilderX on ItemStackStatusBuilder {
  ItemStackStatusBuilder operator <<(ItemStackStatus status) {
    statuses.add(status);
    return this;
  }
}

extension ItemStackListX on List<ItemStack> {
  ItemStack? findFirstByMeta(Item meta) {
    for (final item in this) {
      if (item.meta == meta) {
        return item;
      }
    }
    return null;
  }

  ItemStack? findFirstByName(String name) {
    for (final item in this) {
      if (item.meta.name == name) {
        return item;
      }
    }
    return null;
  }

  ItemStack? findFirstByTag(String tag) {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        return item;
      }
    }
    return null;
  }

  ItemStack? findFirstByTags(Iterable<String> tags) {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        return item;
      }
    }
    return null;
  }

  Iterable<ItemStack> findAllByTag(String tag) sync* {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        yield item;
      }
    }
  }

  Iterable<ItemStack> findAllByTags(Iterable<String> tags) sync* {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        yield item;
      }
    }
  }

  void addItemOrMergeAll(List<ItemStack> additions) {
    for (final addition in additions) {
      addItemOrMerge(addition);
    }
  }

  void addItemOrMerge(ItemStack addition) {
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

  bool removeStack(ItemStack stack) {
    return remove(stack);
  }

  void cleanEmptyStack() {
    retainWhere((stack) => stack.isNotEmpty);
  }
}

typedef ItemTypeMatcher = bool Function(Item item);
typedef ItemStackMatcher = ItemStackMatchResult Function(ItemStack stack);

enum ItemStackMatchResult {
  matched,
  typeUnmatched,
  massUnmatched;

  bool get isMatched => this == matched;
}

class ItemMatcher {
  final ItemTypeMatcher typeOnly;
  final ItemStackMatcher exact;

  const ItemMatcher({required this.typeOnly, required this.exact});

  static ItemMatcher hasTags(List<String> tags) => ItemMatcher(
    typeOnly: (item) => item.hasTags(tags),
    exact: (item) => item.meta.hasTags(tags) ? .matched : .typeUnmatched,
  );

  static ItemMatcher hasAnyTag(List<String> tags) => ItemMatcher(
    typeOnly: (item) => item.hasAnyTag(tags),
    exact: (item) => item.meta.hasAnyTag(tags) ? .matched : .typeUnmatched,
  );

  static ItemMatcher hasComp(List<Type> compTypes) => ItemMatcher(
    typeOnly: (item) => item.hasComps(compTypes),
    exact: (item) => item.meta.hasComps(compTypes) ? .matched : .typeUnmatched,
  );
  static ItemMatcher any = ItemMatcher(typeOnly: (_) => true, exact: (_) => .matched);
}

extension ItemStackMatcherX on ItemStackMatcher {
  Matcher<ItemStack> get bool =>
      (stack) => this(stack).isMatched;
}

extension ItemMatcherX on ItemMatcher {
  Iterable<Item> filterTypeMatchedItems(Iterable<Item> items, {bool requireMatched = true}) sync* {
    for (final item in items) {
      if (requireMatched) {
        if (typeOnly(item)) {
          yield item;
        }
      } else {
        if (!typeOnly(item)) {
          yield item;
        }
      }
    }
  }

  Iterable<ItemStack> filterExactMatchedStacks(Iterable<ItemStack> stacks, {bool requireMatched = true}) sync* {
    for (final stack in stacks) {
      if (requireMatched) {
        if (exact(stack).isMatched) {
          yield stack;
        }
      } else {
        if (!exact(stack).isMatched) {
          yield stack;
        }
      }
    }
  }

  Iterable<ItemStack> filterTypedMatchedStacks(Iterable<ItemStack> stacks, {bool requireMatched = true}) sync* {
    for (final stack in stacks) {
      if (requireMatched) {
        if (typeOnly(stack.meta)) {
          yield stack;
        }
      } else {
        if (!typeOnly(stack.meta)) {
          yield stack;
        }
      }
    }
  }
}
